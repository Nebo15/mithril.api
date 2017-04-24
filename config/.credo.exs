%{
  configs: [
    %{
      color: true,
      name: "default",
      files: %{
        included: ["lib/"]
      },
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.Nesting, false}
      ]
    }
  ]
}
