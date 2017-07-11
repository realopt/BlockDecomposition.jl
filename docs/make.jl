using Documenter, BlockDecomposition

makedocs(
    modules = [BlockDecomposition],
    format = :html,
    sitename = "BlockDecomposition",
    pages    = Any[
        "Home"   => "index.md",
        "Installation"   => "installation.md",
        "Introduction"   => "introduction.md",
        "Basic"   => "basic.md",
        "Callbacks" => "callbacks.md",
        "Advanced" => "advanced.md",
        "BlockSolverInterface" => "BlockSolverInterface.md"
    ]


)
