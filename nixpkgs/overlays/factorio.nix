self: super: {
    factorio = super.factorio.override {
      username = "nelsonjeppesen";
      releaseType = "demo";
    };
}
