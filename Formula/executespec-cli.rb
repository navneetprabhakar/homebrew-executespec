class ExecutespecCli < Formula
  desc "CLI for specs, plan gates, local-hands runs, and run evidence"
  homepage "https://dev.executespec.ai"
  url "https://github.com/navneetprabhakar/executespec-cli.git",
      revision: "62ce5a412e69fff7dead868936df4a4836d12260"
  version "0.4.2"
  license :cannot_represent
  head "https://github.com/navneetprabhakar/executespec-cli.git", branch: "main"

  depends_on "node"

  def install
    system "npm", "ci", "--ignore-scripts"
    system "npm", "run", "build", "-w", "@executespec/core"
    system "npm", "run", "build", "-w", "@executespec/cli"

    core_pack = npm_pack_workspace("@executespec/core")
    cd "cli" do
      system "npm", "install", "--omit=dev", *std_npm_args
    end

    # The CLI and core are developed in this monorepo and the CLI can move ahead of the
    # published core package. Replace the nested dependency with the source-built core pack.
    cd libexec/"lib/node_modules/@executespec/cli" do
      system "npm", "install", "--omit=dev", "--no-save", *std_npm_args(prefix: false), core_pack
    end

    bin.install_symlink libexec/"bin/executespec"
    bin.install_symlink libexec/"bin/es"
    bin.install_symlink libexec/"bin/eslocal"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/executespec --version")
    assert_match version.to_s, shell_output("#{bin}/es --version")
    assert_match version.to_s, shell_output("#{bin}/eslocal --version")
    assert_match "eslocal <command>", shell_output("#{bin}/executespec --help")
  end

  private

  def npm_pack_workspace(workspace)
    output = shell_output("npm pack -w #{workspace} --ignore-scripts --pack-destination #{buildpath}")
    buildpath/output.lines.fetch(-1).chomp
  end
end
