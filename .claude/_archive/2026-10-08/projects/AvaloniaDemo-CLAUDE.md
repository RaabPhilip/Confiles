# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a demo project for getting familiar with the Avalonia UI framework (.NET). It is currently the unmodified Avalonia template output — a single window with no view models, MVVM framework, or dependency injection wired up yet.

## Commands

- Build: `dotnet build`
- Run: `dotnet run`
- Hot-reload dev loop: `dotnet watch`
- There is no test project yet; `dotnet test` has nothing to run.

Note: `TreatWarningsAsErrors` is enabled in `AvaloniaDemo.csproj`, so build warnings will fail the build.

## Architecture

- Target framework: `net10.0`, `OutputType=WinExe` (desktop app), Avalonia 12.1.3 with the Fluent theme and Inter font.
- Entry point is `Program.cs`: `Main` builds the `AppBuilder` (`BuildAvaloniaApp`) and starts the classic desktop lifetime. Avalonia/third-party APIs must not be touched before `AppMain` runs.
- `App.axaml` / `App.axaml.cs` define the `Application` (theme setup via `Application.Styles`) and, in `OnFrameworkInitializationCompleted`, set `MainWindow` on the classic desktop lifetime.
- `MainWindow.axaml` / `MainWindow.axaml.cs` is the (currently only) window — standard Avalonia XAML + code-behind pairing, no bindings or view model yet.
- `app.manifest` only affects Windows builds (window transparency / embedded controls behavior) and can be ignored on other platforms.
- `AvaloniaUI.DiagnosticsSupport` is referenced only for `Debug` builds (dev tools), excluded from non-Debug configurations.

As the app grows past the template, expect the natural next steps to be introducing a `ViewModels`/`Views` split and a binding pattern (Avalonia's `ReactiveUI` or the MVVM community toolkit are the common choices) — don't assume either is in place until you see it added.
