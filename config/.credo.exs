%{
  configs: [
    %{
      color: true,
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: ["lib/trump_api/tasks.ex"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.Specs, false},
      ]
    }
  ]
}
