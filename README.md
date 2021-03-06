[![icon](./docs/images/header.png)](https://www.nuget.org/packages/WPF_Neumorphism_Plus/)

# WPF-Neumorphism-Plus

[![nuget](https://img.shields.io/nuget/v/WPF_Neumorphism_Plus?style=flat)](https://www.nuget.org/packages/WPF_Neumorphism_Plus/)

**WPF-Neumorphism-Plus** is a library for Neumorphism UI in WPF.  

- [QuickStart](https://ryokohbato.github.io/WPF-Neumorphism-Plus/#how-to-create-a-standard-neumorphism-ui-with-wpf-neumorphism-plus)

- [Download](https://www.nuget.org/packages/WPF_Neumorphism_Plus/)

- [Document](https://ryokohbato.github.io/WPF-Neumorphism-Plus/)

## DEMO

![screenshot_01](./docs/images/screenshot_light.gif)
![screenshot_02](./docs/images/screenshot_dark.png)

Sample code for this app can be found [here](https://github.com/ryokohbato/WPF-Neumorphism-Plus/tree/master/SampleApp).

## Features

This library allows you to implement a Neumorphism UI as an effect on any element of your WPF application.

## Requirement

### .NET

- .NET 5
- .NET Framework 4.x
- .NET Core 3.1

### OS

- Windows

## Installation

### Visual Studio

``Tools > NuGet Package Manager > Manage NuGet Packages for Solution...``

![Nuget on VS](./docs/images/nuget_vs.png)

### Package Manager
  
```bash
PM> Install-Package WPF_Neumorphism_Plus -Version [version]
```

### .NET CLI

```bash
$ dotnet add package WPF_Neumorphism_Plus --version [version]
```

## Usage

1. Install **WPF_Neumorphism_Plus**.

1. Add new effect from ``Appearance > Effect``  
![add Effect](./docs/images/addEffect.png)

1. Select **Neumorphism_Plus_Shader**  
![add WPF_Neumorphism_Plus Effect](./docs/images/addEffect2.png)

The default style looks like this.

![default](./docs/images/default.png)

You can specify the direction, size and color of the shadow by specifying the options.

For more information on how to use it, please see [here](https://ryokohbato.github.io/WPF-Neumorphism-Plus/).

------------------------------

## Author

ryokohbato

## License

**WPF-Neumorphism-Plus** is under [MIT License](https://opensource.org/licenses/MIT).
