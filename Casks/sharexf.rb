cask "sharexf" do
  version :latest
  sha256 :no_check

  on_arm do
    url "https://github.com/arc2898/sharexf/releases/latest/download/ShareXF-latest-arm64.dmg"
  end
  on_intel do
    url "https://github.com/arc2898/sharexf/releases/latest/download/ShareXF-latest-x64.dmg"
  end

  name "ShareXF"
  desc "Share mouse, keyboard, clipboard, files and screens with other devices"
  homepage "https://github.com/arc2898/sharexf"

  auto_updates true
  depends_on macos: ">= :ventura"

  app "ShareXF.app"
end
