# frozen_string_literal: true

Given("I am running on a Lubuntu system") do
  allow(LubuntuGui).to receive(:lubuntu?).and_return(true)
end

Given("there are open windows on the desktop") do
  allow(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -l -x").and_return({
    stdout: "0x01000003  0 firefox.Firefox  Mozilla Firefox\n0x01000004  1 leafpad.Leafpad  Untitled - Leafpad",
    stderr: "",
    success: true,
    exit_code: 0
  })
end

Given("there is a window with ID {string}") do |window_id|
  @window_id = window_id
  allow(LubuntuGui::CommandExecutor).to receive(:safe_execute).with(/wmctrl.*#{window_id}/).and_return({
    stdout: "",
    stderr: "",
    success: true,
    exit_code: 0
  })
end

Given("there are multiple virtual desktops") do
  allow(LubuntuGui::CommandExecutor).to receive(:safe_execute).with("wmctrl -d").and_return({
    stdout: "0  * DG: 1920x1080  VP: 0,0  WA: 0,24 1920x1056  Desktop 1\n1  - DG: 1920x1080  VP: 0,0  WA: 0,24 1920x1056  Desktop 2",
    stderr: "",
    success: true,
    exit_code: 0
  })
end

When("I request a list of windows") do
  @windows = LubuntuGui::WindowManager.list_windows
end

When("I focus the window") do
  @result = LubuntuGui::WindowManager.focus_window(@window_id)
end

When("I move the window to coordinates {int}, {int}") do |x, y|
  @result = LubuntuGui::WindowManager.move_window(@window_id, x, y)
  @expected_x = x
  @expected_y = y
end

When("I resize the window to {int}x{int}") do |width, height|
  @result = LubuntuGui::WindowManager.resize_window(@window_id, width, height)
  @expected_width = width
  @expected_height = height
end

When("I close the window") do
  @result = LubuntuGui::WindowManager.close_window(@window_id)
end

When("I switch to desktop {int}") do |desktop_number|
  @result = LubuntuGui::WindowManager.switch_desktop(desktop_number)
  @expected_desktop = desktop_number
end

Then("I should receive an array of window information") do
  expect(@windows).to be_an(Array)
  expect(@windows.length).to be > 0
  expect(@windows.first).to have_key(:id)
  expect(@windows.first).to have_key(:title)
end

Then("the window should become active") do
  expect(@result).to be true
end

Then("the window should be positioned at {int}, {int}") do |x, y|
  expect(@result).to be true
  expect(@expected_x).to eq(x)
  expect(@expected_y).to eq(y)
end

Then("the window should have dimensions {int}x{int}") do |width, height|
  expect(@result).to be true
  expect(@expected_width).to eq(width)
  expect(@expected_height).to eq(height)
end

Then("the window should be closed") do
  expect(@result).to be true
end

Then("the active desktop should be {int}") do |desktop_number|
  expect(@result).to be true
  expect(@expected_desktop).to eq(desktop_number)
end

