cask "snyvi" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.4.0"
  sha256 arm:   "9055bb758f2a2bbd669960df279a3345916935eb9c06d1c3af110db348366029",
         intel: "9855e9c5b42b5f4940c370190b4a5ec03eaf5822ac42b69b19a5c33deb371454"

  url "https://github.com/snymrova/snyvi/releases/download/v#{version}/snyvi-#{version}-#{arch}-apple-darwin.tar.gz",
      verified: "github.com/snymrova/snyvi/"
  name "snyvi"
  desc "Fast, beautiful viewer for the documents your agents produce"
  homepage "https://mrova.rocks/snyvi"

  depends_on macos: ">= :big_sur"

  app "snyvi-#{version}-#{arch}-apple-darwin/snyvi.app"
  # The command line, from inside the bundle that was just installed. One
  # download carries the window and the CLI, so `brew install --cask snyvi`
  # leaves the reader with both `snyvi` and something to double-click.
  binary "#{appdir}/snyvi.app/Contents/MacOS/snyvi"

  # See the header of packaging/homebrew.sh: ad-hoc signed, so without this the
  # first open is refused as coming from an unidentified developer.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/snyvi.app"]
  end

  # The daemon outlives the window, and an upgrade that swaps the binary under
  # a running one leaves the old code serving. Stop it first; `snyvi stop` is
  # the same command the reader would type.
  uninstall quit:   "rocks.ohmydog.snyvi",
            script: {
              executable:   "#{appdir}/snyvi.app/Contents/MacOS/snyvi",
              args:         ["stop"],
              must_succeed: false,
            }

  # The library is the reader's documents. It is never removed by an
  # uninstall, only by `brew zap`, which says out loud that it deletes data.
  zap trash: [
    "~/Library/Application Support/snyvi",
    "~/Library/Application Support/rocks.ohmydog.snyvi",
    "~/Library/Saved Application State/rocks.ohmydog.snyvi.savedState",
    "~/Library/WebKit/rocks.ohmydog.snyvi",
  ]
end
