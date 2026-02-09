# editorconfig.nix - Global EditorConfig settings
#
# Defines a project-agnostic .editorconfig that applies to all files.
# Ensures consistent formatting across editors (Neovim, VS Code, etc.):
# - UTF-8 encoding, LF line endings
# - 2-space indentation (matching Nix ecosystem conventions)
# - Trim trailing whitespace and ensure final newline
{ ... }:
{
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_width = 0; # No line width limit (0 = disabled)
        indent_style = "space";
        indent_size = 2;
      };
    };
  };
}
