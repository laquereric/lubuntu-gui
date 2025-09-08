# frozen_string_literal: true

RSpec.describe LubuntuGui do
  it "has a version number" do
    expect(LubuntuGui::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields configuration object" do
      expect { |b| LubuntuGui.configure(&b) }.to yield_with_args(LubuntuGui::Configuration)
    end
  end

  describe ".configuration" do
    it "returns configuration object" do
      expect(LubuntuGui.configuration).to be_a(LubuntuGui::Configuration)
    end
  end

  describe ".reset_configuration!" do
    it "resets configuration to defaults" do
      LubuntuGui.configure { |c| c.debug = true }
      expect(LubuntuGui.configuration.debug).to be true
      
      LubuntuGui.reset_configuration!
      expect(LubuntuGui.configuration.debug).to be false
    end
  end

  describe ".lubuntu?" do
    context "when DESKTOP_SESSION contains lubuntu" do
      before { allow(ENV).to receive(:[]).with("DESKTOP_SESSION").and_return("lubuntu") }
      
      it "returns true" do
        expect(LubuntuGui.lubuntu?).to be true
      end
    end

    context "when XDG_CURRENT_DESKTOP contains lxqt" do
      before do
        allow(ENV).to receive(:[]).with("DESKTOP_SESSION").and_return(nil)
        allow(ENV).to receive(:[]).with("XDG_CURRENT_DESKTOP").and_return("LXQt")
      end
      
      it "returns true" do
        expect(LubuntuGui.lubuntu?).to be true
      end
    end

    context "when neither environment variable indicates Lubuntu" do
      before do
        allow(ENV).to receive(:[]).with("DESKTOP_SESSION").and_return("gnome")
        allow(ENV).to receive(:[]).with("XDG_CURRENT_DESKTOP").and_return("GNOME")
      end
      
      it "returns false" do
        expect(LubuntuGui.lubuntu?).to be false
      end
    end
  end

  describe ".desktop_environment" do
    it "returns desktop environment name" do
      allow(ENV).to receive(:[]).with("XDG_CURRENT_DESKTOP").and_return("LXQt")
      expect(LubuntuGui.desktop_environment).to eq("LXQt")
    end
  end

  describe ".lxqt_available?" do
    it "checks for lxqt-config command" do
      expect(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("lxqt-config")
      LubuntuGui.lxqt_available?
    end
  end

  describe ".openbox_available?" do
    it "checks for openbox command" do
      expect(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("openbox")
      LubuntuGui.openbox_available?
    end
  end
end

