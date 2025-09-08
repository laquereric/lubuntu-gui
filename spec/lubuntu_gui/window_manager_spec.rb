# frozen_string_literal: true

RSpec.describe LubuntuGui::WindowManager do
  describe ".list_windows" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
        allow(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -l -x").and_return({
          stdout: "0x01000003  0 firefox.Firefox  Mozilla Firefox\n0x01000004  1 leafpad.Leafpad  Untitled - Leafpad",
          stderr: "",
          success: true,
          exit_code: 0
        })
      end

      it "returns array of window information" do
        windows = LubuntuGui::WindowManager.list_windows
        expect(windows).to be_an(Array)
        expect(windows.length).to eq(2)
        expect(windows.first[:id]).to eq("0x01000003")
        expect(windows.first[:title]).to eq("Mozilla Firefox")
      end
    end

    context "when neither wmctrl nor xdotool is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).and_return(false)
      end

      it "raises CommandError" do
        expect { LubuntuGui::WindowManager.list_windows }.to raise_error(LubuntuGui::CommandError)
      end
    end
  end

  describe ".focus_window" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
      end

      it "executes wmctrl command to focus window" do
        expect(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -i -a 0x123").and_return({ success: true })
        result = LubuntuGui::WindowManager.focus_window("0x123")
        expect(result).to be true
      end
    end
  end

  describe ".move_window" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
      end

      it "executes wmctrl command to move window" do
        expect(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -i -r 0x123 -e 0,100,200,-1,-1").and_return({ success: true })
        result = LubuntuGui::WindowManager.move_window("0x123", 100, 200)
        expect(result).to be true
      end
    end
  end

  describe ".resize_window" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
      end

      it "executes wmctrl command to resize window" do
        expect(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -i -r 0x123 -e 0,-1,-1,800,600").and_return({ success: true })
        result = LubuntuGui::WindowManager.resize_window("0x123", 800, 600)
        expect(result).to be true
      end
    end
  end

  describe ".close_window" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
      end

      it "executes wmctrl command to close window" do
        expect(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -i -c 0x123").and_return({ success: true })
        result = LubuntuGui::WindowManager.close_window("0x123")
        expect(result).to be true
      end
    end
  end

  describe ".switch_desktop" do
    context "when wmctrl is available" do
      before do
        allow(LubuntuGui::CommandExecutor).to receive(:command_exists?).with("wmctrl").and_return(true)
      end

      it "executes wmctrl command to switch desktop" do
        expect(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -s 2").and_return({ success: true })
        result = LubuntuGui::WindowManager.switch_desktop(2)
        expect(result).to be true
      end
    end
  end

  describe ".find_windows_by_title" do
    before do
      allow(LubuntuGui::WindowManager).to receive(:list_windows).and_return([
        { id: "0x123", title: "Mozilla Firefox", class: "firefox" },
        { id: "0x124", title: "Untitled - Leafpad", class: "leafpad" }
      ])
    end

    it "finds windows matching title" do
      windows = LubuntuGui::WindowManager.find_windows_by_title("Firefox")
      expect(windows.length).to eq(1)
      expect(windows.first[:id]).to eq("0x123")
    end

    it "performs case-insensitive search" do
      windows = LubuntuGui::WindowManager.find_windows_by_title("firefox")
      expect(windows.length).to eq(1)
      expect(windows.first[:id]).to eq("0x123")
    end
  end
end

