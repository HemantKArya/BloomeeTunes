#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// "Bloomee🌸" (escaped so the source stays plain ASCII).
constexpr wchar_t kWindowTitle[] = L"Bloomee\U0001F338";
constexpr wchar_t kWindowClass[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
constexpr wchar_t kInstanceMutex[] = L"Local\\BloomeeX.BloomeeTunes";

// Native menus (tray menu, system menu) follow the app's dark theme instead
// of the classic light style. uxtheme exports these by ordinal only; they
// exist from Windows 10 1903 (build 18362), so older builds are skipped.
void UseDarkMenus() {
  using RtlGetVersionFn = LONG(WINAPI*)(OSVERSIONINFOW*);
  auto rtl_get_version = reinterpret_cast<RtlGetVersionFn>(
      ::GetProcAddress(::GetModuleHandleW(L"ntdll.dll"), "RtlGetVersion"));
  OSVERSIONINFOW version{sizeof(version)};
  if (rtl_get_version == nullptr || rtl_get_version(&version) != 0 ||
      version.dwBuildNumber < 18362) {
    return;
  }

  HMODULE uxtheme =
      ::LoadLibraryExW(L"uxtheme.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
  if (uxtheme == nullptr) return;
  enum class PreferredAppMode { kDefault, kAllowDark, kForceDark };
  using SetPreferredAppModeFn = PreferredAppMode(WINAPI*)(PreferredAppMode);
  using FlushMenuThemesFn = void(WINAPI*)();
  auto set_preferred_app_mode = reinterpret_cast<SetPreferredAppModeFn>(
      ::GetProcAddress(uxtheme, MAKEINTRESOURCEA(135)));
  auto flush_menu_themes = reinterpret_cast<FlushMenuThemesFn>(
      ::GetProcAddress(uxtheme, MAKEINTRESOURCEA(136)));
  if (set_preferred_app_mode == nullptr) return;
  set_preferred_app_mode(PreferredAppMode::kForceDark);
  if (flush_menu_themes != nullptr) flush_menu_themes();
}

// Brings the running instance forward, including from the tray (hidden).
void ActivateRunningInstance() {
  HWND existing = ::FindWindowW(kWindowClass, kWindowTitle);
  if (existing == nullptr) return;
  ::ShowWindow(existing, ::IsIconic(existing) ? SW_RESTORE : SW_SHOW);
  ::SetForegroundWindow(existing);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // One instance per user session: both would share one database, and a
  // second launch is how users reopen an app hidden in the tray.
  HANDLE instance_mutex = ::CreateMutexW(nullptr, TRUE, kInstanceMutex);
  if (instance_mutex != nullptr && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    ActivateRunningInstance();
    ::CloseHandle(instance_mutex);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  UseDarkMenus();

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  // "Bloomee🌸" (escaped so the source stays plain ASCII).
  if (!window.Create(L"Bloomee\U0001F338", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  if (instance_mutex != nullptr) ::CloseHandle(instance_mutex);
  return EXIT_SUCCESS;
}
