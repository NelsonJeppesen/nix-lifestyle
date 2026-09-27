# plymouth.nix - Plymouth boot splash: three-frame fullscreen animation.
#
# Frames are cut from `../bootlogo/loop.webm` at build time, so picking
# different moments is a parameter change here rather than new blobs in
# git.
#
# Why three slow frames and not the clip: whenever DeviceScale != 1 the
# script plugin draws every sprite through ply_pixel_buffer's per-pixel
# bilinear upscale (the memcpy fast path needs canvas and image scales to
# match, and script images are always 1x). A fullscreen repaint on a
# 2880x1800 panel costs ~130 ms, so a 25 fps loop managed ~8 fps and
# starved plymouthd's event loop: every client request during boot
# stalled ~4 s and Graphical Interface slipped from ~10 s to ~22 s. One
# repaint per `holdTicks` keeps plymouthd idle most of the time; going
# much below ~0.25 s per frame brings the stall back.
#
# 1440x900 is the source clip's native size and exactly half the
# 2880x1800 panel, so that host's DeviceScale=2 makes the frames fill the
# screen with no script-side resize. On any other panel the script scales
# them once at init.
{ pkgs, ... }:
let
  width = 1440;
  height = 900;

  # Seconds into loop.webm for each frame. The clip pans, so frames close
  # together shift the scene gently instead of jumping across it.
  frameTimes = [
    "0"
    "0.5"
    "1"
  ];

  # The script plugin's refresh callback runs at a fixed 50 Hz, so 25
  # ticks holds each frame for 0.5 s.
  holdTicks = 25;

  frames =
    pkgs.runCommand "plymouth-bootlogo-frames"
      {
        nativeBuildInputs = [ pkgs.ffmpeg-headless ];
      }
      ''
        mkdir -p $out
        i=0
        for t in ${builtins.concatStringsSep " " frameTimes}; do
          ffmpeg -nostdin -loglevel error -ss "$t" -i ${../bootlogo/loop.webm} \
            -vf "scale=${toString width}:${toString height}:flags=lanczos" \
            -frames:v 1 -f image2 -c:v png $out/frame-$i.png
          i=$((i + 1))
        done
      '';

  themeFile = pkgs.writeText "bootlogo.plymouth" ''
    [Plymouth Theme]
    Name=bootlogo
    Description=Three-frame fullscreen boot splash
    ModuleName=script

    [script]
    ImageDir=@themeDir@
    ScriptFile=@themeDir@/bootlogo.script
  '';

  themeScript = pkgs.writeText "bootlogo.script" ''
    ## Three-frame fullscreen splash, played ping-pong. Each frame change
    ## is one fullscreen repaint, so frames are held for ${toString holdTicks}
    ## ticks of the 50 Hz refresh callback.

    Window.SetBackgroundTopColor(0, 0, 0);
    Window.SetBackgroundBottomColor(0, 0, 0);

    screen.w = Window.GetWidth(0);
    screen.h = Window.GetHeight(0);
    screen.half.w = screen.w / 2;
    screen.half.h = screen.h / 2;

    frame_count = ${toString (builtins.length frameTimes)};
    hold_ticks = ${toString holdTicks};

    for (i = 0; i < frame_count; i++)
      {
        frame[i] = Image("frame-" + i + ".png");
        # No-op where DeviceScale already makes the canvas frame-sized.
        if (frame[i].GetWidth() != screen.w || frame[i].GetHeight() != screen.h)
          frame[i] = frame[i].Scale(screen.w, screen.h);
      }

    anim.sprite = Sprite(frame[0]);
    anim.sprite.SetX(Window.GetX());
    anim.sprite.SetY(Window.GetY());
    # Behind every text sprite below, which all default to Z = 0.
    anim.sprite.SetZ(-100);

    # Ping-pong (0 1 2 1 0 ...) so the wrap is one step like every other
    # instead of a jump from the last frame straight back to the first.
    cycle = 2 * frame_count - 2;
    tick = 0;
    shown = 0;

    fun refresh_callback ()
      {
        step = Math.Int(tick / hold_ticks) % cycle;
        if (step < frame_count)
          index = step;
        else
          index = cycle - step;

        # SetImage forces a full repaint even for the same image, so only
        # call it when the frame actually changes.
        if (index != shown)
          {
            anim.sprite.SetImage(frame[index]);
            shown = index;
          }
        tick++;
      }

    Plymouth.SetRefreshFunction(refresh_callback);

    //-------------------------------- Password prompt --------------------------------
    # Root is LUKS; this only shows when the TPM2 unlock falls through to
    # a passphrase. Without it the passphrase would have to be typed blind.
    prompt = null;
    bullets = null;
    message = null;
    question = null;
    answer = null;
    bullet.image = Image.Text("*", 1, 1, 1);

    fun DisplayPasswordCallback (nil, bulletCount)
      {
        prompt.image = Image.Text("Enter Password", 1, 1, 1);
        prompt.sprite = Sprite(prompt.image);
        prompt.sprite.SetX(screen.half.w - prompt.image.GetWidth() / 2);
        prompt.sprite.SetY(screen.h - 4 * prompt.image.GetHeight());

        # Rebuilt from scratch each call so backspace clears properly.
        bullets = null;
        totalWidth = bulletCount * bullet.image.GetWidth();
        startPos = screen.half.w - totalWidth / 2;
        for (i = 0; i < bulletCount; i++)
          {
            bullets[i].sprite = Sprite(bullet.image);
            bullets[i].sprite.SetX(startPos + i * bullet.image.GetWidth());
            bullets[i].sprite.SetY(screen.h - 2 * bullet.image.GetHeight());
          }
      }

    Plymouth.SetDisplayPasswordFunction(DisplayPasswordCallback);

    fun DisplayQuestionCallback (prompt_text, entry)
      {
        question = null;
        answer = null;

        if (entry == "")
          entry = "<answer>";

        question.image = Image.Text(prompt_text, 1, 1, 1);
        question.sprite = Sprite(question.image);
        question.sprite.SetX(screen.half.w - question.image.GetWidth() / 2);
        question.sprite.SetY(screen.h - 4 * question.image.GetHeight());

        answer.image = Image.Text(entry, 1, 1, 1);
        answer.sprite = Sprite(answer.image);
        answer.sprite.SetX(screen.half.w - answer.image.GetWidth() / 2);
        answer.sprite.SetY(screen.h - 2 * answer.image.GetHeight());
      }

    Plymouth.SetDisplayQuestionFunction(DisplayQuestionCallback);

    fun MessageCallback (text)
      {
        message.image = Image.Text(text, 1, 1, 1);
        message.sprite = Sprite(message.image);
        message.sprite.SetX(screen.half.w - message.image.GetWidth() / 2);
        message.sprite.SetY(message.image.GetHeight());
      }

    Plymouth.SetMessageFunction(MessageCallback);

    fun DisplayNormalCallback ()
      {
        prompt = null;
        bullets = null;
        message = null;
        question = null;
        answer = null;
      }

    Plymouth.SetDisplayNormalFunction(DisplayNormalCallback);
  '';

  theme = pkgs.runCommand "plymouth-theme-bootlogo" { } ''
    dir=$out/share/plymouth/themes/bootlogo
    mkdir -p $dir
    cp ${frames}/*.png $dir/
    cp ${themeScript} $dir/bootlogo.script
    substitute ${themeFile} $dir/bootlogo.plymouth --subst-var-by themeDir "$dir"
  '';
in
{
  boot.plymouth = {
    enable = true;
    theme = "bootlogo";
    themePackages = [ theme ];
  };
}
