using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Effects;

namespace WPF_Neumorphism_Plus
{
    public class WPF_Neumorphism_Plus : Control
    {
        static WPF_Neumorphism_Plus()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(WPF_Neumorphism_Plus), new FrameworkPropertyMetadata(typeof(WPF_Neumorphism_Plus)));
        }
    }

    /// <summary>
    /// Make shadow of Neumorphism UI
    /// </summary>
    public class Neumorphism_Plus_Shader : ShaderEffect
    {
        public Neumorphism_Plus_Shader()
        {
            var pixelShader = new PixelShader();
            try
            {
                // Load shader effect.
                string assemblyName = typeof(Neumorphism_Plus_Shader).Assembly.GetName().Name;
                string uri = "pack://application:,,,/" + assemblyName + ";component/Effect/Effect.ps";

                pixelShader.UriSource = new Uri(uri, UriKind.RelativeOrAbsolute);
            }
            catch (Exception e)
            {
                // Show compile errors
                MessageBox.Show(e.ToString());
                Environment.Exit(1);
            }

            this.PixelShader = pixelShader;
            this.DdxUvDdyUvRegisterIndex = 8;
            
            // Update each value (required)
            UpdateShaderValue(InputProperty);
            UpdateShaderValue(ShadowOffsetXProperty);
            UpdateShaderValue(ShadowOffsetYProperty);
            UpdateShaderValue(ShadowBlurRadiusProperty);
            UpdateShaderValue(ShadowSpreadRadiusProperty);
            UpdateShaderValue(ShadowPrimaryColorProperty);
            UpdateShaderValue(ShadowSecondaryColorProperty);
            UpdateShaderValue(ShadowInsetProperty);
            UpdateShaderValue(ShadowRenderingModeProperty);

        }

        ////////////////////////   Input   ////////////////////////

        public Brush Input
        {
            get { return (Brush)GetValue(InputProperty); }
            set { SetValue(InputProperty, value); }
        }

        public static readonly DependencyProperty InputProperty =
            RegisterPixelShaderSamplerProperty("Input", typeof(Neumorphism_Plus_Shader), 0);

        ////////////////////////   OffsetX   ////////////////////////
        /// <summary>
        /// double (default : 7.0)
        /// The horizontal offset of the shadow
        /// </summary>
        public double OffsetX
        {
            get { return (double)GetValue(ShadowOffsetXProperty); }
            set { SetValue(ShadowOffsetXProperty, value); }
        }

        public static readonly DependencyProperty ShadowOffsetXProperty =
                DependencyProperty.Register(
                    "OffsetX",
                    typeof(double),
                    typeof(Neumorphism_Plus_Shader),
                    new UIPropertyMetadata(7.0,
                        (DependencyObject d, DependencyPropertyChangedEventArgs e) =>
                        {
                            OffsetXRegisterCallback(d, e);

                            if (d is Neumorphism_Plus_Shader obj)
                                obj.OnShadowOffsetXChanged((double)e.NewValue);
                        })
                );

        static readonly PropertyChangedCallback OffsetXRegisterCallback = PixelShaderConstantCallback(0);

        protected void OnShadowOffsetXChanged(double newValue)
        {
            if (Inset == 0)
            {
                this.PaddingLeft = Math.Abs(newValue) + BlurRadius + SpreadRadius;
                this.PaddingRight = Math.Abs(newValue) + BlurRadius + SpreadRadius;
                this.PaddingTop = Math.Abs(OffsetY) + BlurRadius + SpreadRadius;
                this.PaddingBottom = Math.Abs(OffsetY) + BlurRadius + SpreadRadius;
            }
            else
            {
                this.PaddingLeft = 0;
                this.PaddingRight = 0;
                this.PaddingTop = 0;
                this.PaddingBottom = 0;
            }
        }

        ///////////////////////   OffsetY   ////////////////////////
        /// <summary>
        /// double (default : 5.0)
        /// The vertical offset of the shadow
        /// </summary>
        public double OffsetY
        {
            get { return (double)GetValue(ShadowOffsetYProperty); }
            set { SetValue(ShadowOffsetYProperty, value); }
        }

        public static readonly DependencyProperty ShadowOffsetYProperty =
                DependencyProperty.Register(
                    "OffsetY",
                    typeof(double),
                    typeof(Neumorphism_Plus_Shader),
                    new UIPropertyMetadata(5.0,
                        (DependencyObject d, DependencyPropertyChangedEventArgs e) =>
                        {
                            OffsetYRegisterCallback(d, e);

                            if (d is Neumorphism_Plus_Shader obj)
                                obj.OnShadowOffsetYChanged((double)e.NewValue);
                        })
                );

        static readonly PropertyChangedCallback OffsetYRegisterCallback = PixelShaderConstantCallback(1);

        protected void OnShadowOffsetYChanged(double newValue)
        {
            if (Inset == 0)
            {
                this.PaddingLeft = Math.Abs(OffsetX) + BlurRadius + SpreadRadius;
                this.PaddingRight = Math.Abs(OffsetX) + BlurRadius + SpreadRadius;
                this.PaddingTop = Math.Abs(newValue) + BlurRadius + SpreadRadius;
                this.PaddingBottom = Math.Abs(newValue) + BlurRadius + SpreadRadius;
            }
            else
            {
                this.PaddingLeft = 0;
                this.PaddingRight = 0;
                this.PaddingTop = 0;
                this.PaddingBottom = 0;
            }
        }

        ///////////////////////   BlurRadius   ////////////////////////
        /// <summary>
        /// double (default : 10.0)
        /// The radius of the shadow's blur effect
        /// </summary>
        public double BlurRadius
        {
            get { return (double)GetValue(ShadowBlurRadiusProperty); }
            set { SetValue(ShadowBlurRadiusProperty, value); }
        }

        public static readonly DependencyProperty ShadowBlurRadiusProperty =
                DependencyProperty.Register(
                    "BlurRadius",
                    typeof(double),
                    typeof(Neumorphism_Plus_Shader),
                    new UIPropertyMetadata(10.0,
                        (DependencyObject d, DependencyPropertyChangedEventArgs e) =>
                        {
                            BlurRadiusRegisterCallback(d, e);

                            if (d is Neumorphism_Plus_Shader obj)
                                obj.OnShadowBlurRadiusChanged((double)e.NewValue);
                        })
                );

        static readonly PropertyChangedCallback BlurRadiusRegisterCallback = PixelShaderConstantCallback(2);

        protected void OnShadowBlurRadiusChanged(double newValue)
        {
            if (Inset == 0)
            {
                this.PaddingLeft = Math.Abs(OffsetX) + newValue + SpreadRadius;
                this.PaddingRight = Math.Abs(OffsetX) + newValue + SpreadRadius;
                this.PaddingTop = Math.Abs(OffsetY) + newValue + SpreadRadius;
                this.PaddingBottom = Math.Abs(OffsetY) + newValue + SpreadRadius;
            }
            else
            {
                this.PaddingLeft = 0;
                this.PaddingRight = 0;
                this.PaddingTop = 0;
                this.PaddingBottom = 0;
            }
        }

        ///////////////////////   SpreadRadius   ////////////////////////
        /// <summary>
        /// double (default : 5.0)
        /// The radius of the shadow's spread effect
        /// </summary>
        public double SpreadRadius
        {
            get { return (double)GetValue(ShadowSpreadRadiusProperty); }
            set { SetValue(ShadowSpreadRadiusProperty, value); }
        }

        public static readonly DependencyProperty ShadowSpreadRadiusProperty =
                DependencyProperty.Register(
                    "SpreadRadius",
                    typeof(double),
                    typeof(Neumorphism_Plus_Shader),
                    new UIPropertyMetadata(5.0,
                        (DependencyObject d, DependencyPropertyChangedEventArgs e) =>
                        {
                            SpreadRadiusRegisterCallback(d, e);

                            if (d is Neumorphism_Plus_Shader obj)
                                obj.OnShadowSpreadRadiusChanged((double)e.NewValue);
                        })
                );

        static readonly PropertyChangedCallback SpreadRadiusRegisterCallback = PixelShaderConstantCallback(3);

        protected void OnShadowSpreadRadiusChanged(double newValue)
        {
            if (Inset == 0)
            {
                this.PaddingLeft = Math.Abs(OffsetX) + BlurRadius + newValue;
                this.PaddingRight = Math.Abs(OffsetX) + BlurRadius + newValue;
                this.PaddingTop = Math.Abs(OffsetY) + BlurRadius + newValue;
                this.PaddingBottom = Math.Abs(OffsetY) + BlurRadius + newValue;
            }
            else
            {
                this.PaddingLeft = 0;
                this.PaddingRight = 0;
                this.PaddingTop = 0;
                this.PaddingBottom = 0;
            }
        }

        ////////////////////////   PrimaryColor   ////////////////////////
        /// <summary>
        /// Color (default : Colors.Gray)
        /// The primary color of the shadow
        /// </summary>
        public Color PrimaryColor
        {
            get { return (Color)GetValue(ShadowPrimaryColorProperty); }
            set { SetValue(ShadowPrimaryColorProperty, value); }
        }

        public static readonly DependencyProperty ShadowPrimaryColorProperty =
            DependencyProperty.Register(
                "PrimaryColor",
                typeof(Color),
                typeof(Neumorphism_Plus_Shader),
                new UIPropertyMetadata(Colors.Gray, PixelShaderConstantCallback(4))
            );

        ////////////////////////   SecondaryColor   ////////////////////////
        /// <summary>
        /// Color (default : Colors.White)
        /// The secondary color of the shadow
        /// </summary>
        public Color SecondaryColor
        {
            get { return (Color)GetValue(ShadowSecondaryColorProperty); }
            set { SetValue(ShadowSecondaryColorProperty, value); }
        }

        public static readonly DependencyProperty ShadowSecondaryColorProperty =
            DependencyProperty.Register(
                "SecondaryColor",
                typeof(Color),
                typeof(Neumorphism_Plus_Shader),
                new UIPropertyMetadata(Colors.White, PixelShaderConstantCallback(5))
            );

        ////////////////////////   Inset   ////////////////////////
        /// <summary>
        /// double (default : 0.0)
        /// Whether to changes the shadow to one inside the border
        /// expected: 0 or 1
        /// </summary>
        public double Inset
        {
            get { return (double)GetValue(ShadowInsetProperty); }
            set
            {
                try
                {
                    SetValue(ShadowInsetProperty, value);
                }
                catch (Exception e)
                {
                    MessageBox.Show(e.ToString());
                }
            }
        }

        public static readonly DependencyProperty ShadowInsetProperty =
            DependencyProperty.Register(
                "Inset",
                typeof(double),
                typeof(Neumorphism_Plus_Shader),
                new UIPropertyMetadata(0.0,
                    (DependencyObject d, DependencyPropertyChangedEventArgs e) =>
                    {
                        InsetRegisterCallback(d, e);

                        if (d is Neumorphism_Plus_Shader obj)
                            obj.OnShadowInsetChanged((double)e.NewValue);
                    })
            );

        static readonly PropertyChangedCallback InsetRegisterCallback = PixelShaderConstantCallback(6);

        protected void OnShadowInsetChanged(double newValue)
        {
            if (newValue == 0)
            {
                this.PaddingLeft = Math.Abs(OffsetX) + BlurRadius + SpreadRadius;
                this.PaddingRight = Math.Abs(OffsetX) + BlurRadius + SpreadRadius;
                this.PaddingTop = Math.Abs(OffsetY) + BlurRadius + SpreadRadius;
                this.PaddingBottom = Math.Abs(OffsetY) + BlurRadius + SpreadRadius;
            }
            else
            {
                this.PaddingLeft = 0;
                this.PaddingRight = 0;
                this.PaddingTop = 0;
                this.PaddingBottom = 0;
            }
        }

        ////////////////////////   RenderingMode   ////////////////////////
        /// <summary>
        /// double (default : 0.0)
        /// Assign the rendering mode.
        /// 0: default mode;
        /// 1, 2, 3, ... : every mode;
        /// </summary>
        public double RenderingMode
        {
            get { return (double)GetValue(ShadowRenderingModeProperty); }
            set { SetValue(ShadowRenderingModeProperty, value); }
        }

        public static readonly DependencyProperty ShadowRenderingModeProperty =
                DependencyProperty.Register(
                    "RenderingMode",
                    typeof(double),
                    typeof(Neumorphism_Plus_Shader),
                    new UIPropertyMetadata(0.0, PixelShaderConstantCallback(7))
                );
    }
}
