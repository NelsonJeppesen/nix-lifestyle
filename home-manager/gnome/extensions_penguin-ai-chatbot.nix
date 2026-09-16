{ ... }: {

  dconf.settings = {
    "org/gnome/shell/extensions/penguin-ai-chatbot" = {
      human-message-color = "rgb(213,97,153)";
      human-message-text-color = "rgb(255,255,255)";
      llm-message-color = "rgb(54,54,58)";
      llm-message-text-color = "rgb(255,255,255)";
      llm-provider = "openai";
      openai-model = "gpt-5.5";
    };
  };
}
