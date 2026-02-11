{*******************************************************************************
TSkiaButton

Modern, animated button control built with Skia4Delphi.
Designed for smooth, responsive hover interactions with visual polish.
Key Features:

Ripple hover: growing radial white pulse from center
Liquid hover: animated flowing dashed border with phase shift
Breathing pulse: subtle sine-based scale variation + shine overlay
Tilt hover: mouse-position based parallax shift and squash
Customizable: corner radius, effect types, colors, animation speed

*******************************************************************************}
{ TSkiaButton v0.1 alpha                                                       }
{ by Lara Miriam Tamy Reschke                                                   }
{                                                                              }
{------------------------------------------------------------------------------}
{
----Latest Changes

   v 0.1:
    -first release

}
unit uSkiaButton;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math, System.UITypes,
  FMX.Types, FMX.Controls, FMX.StdCtrls,
  FMX.Skia, System.Skia;

type
  TButtonStyle = (bsFlat, bsNeon, bsRetro);
  THoverEffect = (heGlow, heNone, heScaleUp, heRipple, heLiquid, heTilt, heSpot);
  TTransitionType = (ttFade, ttImplode, tsExplode);

  TSkiaButton = class(TSkCustomControl)
  private
    FTimer: TTimer;
    FBackBuffer: ISkImage;

    FText: string;
    FButtonStyle: TButtonStyle;
    FHoverEffect: THoverEffect;
    FShowTransition: TTransitionType;
    FHideTransition: TTransitionType;

    // Color Properties
    FColor: TAlphaColor;
    FHoverColor: TAlphaColor;
    FPressedColor: TAlphaColor;
    FTextColor: TAlphaColor;

    // New Border Properties
    FBorderColor: TAlphaColor;
    FBorderWidth: Single;
    FRoundCorners: Single;
    FShowBorder: Boolean;

    FIsHovered: Boolean;
    FIsPressed: Boolean;
    FMousePos: TPointF;

    FAnimationState: (asIdle, asShowing, asHiding);
    FAnimProgress: Single;
    FTime: Double;

    FOnClick: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;

    procedure SetText(const Value: string);
    procedure SetButtonStyle(const Value: TButtonStyle);
    procedure SetHovered(const Value: Boolean);
    procedure SetPressed(const Value: Boolean);

    // Setters for colors
    procedure SetColor(const Value: TAlphaColor);
    procedure SetHoverColor(const Value: TAlphaColor);
    procedure SetPressedColor(const Value: TAlphaColor);
    procedure SetTextColor(const Value: TAlphaColor);

    // Setters for Border
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetBorderWidth(const Value: Single);
    procedure SetRoundCorners(const Value: Single);
    procedure SetShowBorder(const Value: Boolean);

    procedure OnTimer(Sender: TObject);
    procedure UpdateState;
  protected
    procedure InvalidateBuffer;
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;

    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

    procedure RenderToBuffer(const AWidth, AHeight: Integer);
    procedure DrawCenteredText(const ACanvas: ISkCanvas; const AText: string; const ADest: TRectF; const AFont: ISkFont; const APaint: ISkPaint);

    // Styles
    procedure DrawFlatStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
    procedure DrawNeonStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
    procedure DrawRetroStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowAnimated;
    procedure HideAnimated;

    property Text: string read FText write SetText;
    property ButtonStyle: TButtonStyle read FButtonStyle write SetButtonStyle;
  published
    property HideTransition: TTransitionType read FHideTransition write FHideTransition default ttImplode;
    property ShowTransition: TTransitionType read FShowTransition write FShowTransition default ttFade;
    property HoverEffect: THoverEffect read FHoverEffect write FHoverEffect default heGlow;

    // Color Properties
    property Color: TAlphaColor read FColor write SetColor default $FF3B82F6;
    property HoverColor: TAlphaColor read FHoverColor write SetHoverColor default $FF4B8BF6;
    property PressedColor: TAlphaColor read FPressedColor write SetPressedColor default $FF2A6ACB;
    property TextColor: TAlphaColor read FTextColor write SetTextColor default TAlphaColors.White;

    // New Border Properties
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor default $FF1E3A8A;
    property BorderWidth: Single read FBorderWidth write SetBorderWidth;
    property RoundCorners: Single read FRoundCorners write SetRoundCorners;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

    property Align;
    property Position;
    property Width;
    property Height;
    property Visible;
    property HitTest;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Skia', [TSkiaButton]);
end;

{ TSkiaButton }

constructor TSkiaButton.Create(AOwner: TComponent);
begin
  inherited;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 16;
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := False;

  FText := 'Skia Button';
  FButtonStyle := bsFlat;
  FHoverEffect := heGlow;
  FShowTransition := ttFade;
  FHideTransition := ttImplode;

  // Default Colors
  FColor := $FF3B82F6;       // Blue
  FHoverColor := $FF4B8BF6;  // Lighter Blue
  FPressedColor := $FF2A6ACB; // Darker Blue
  FTextColor := TAlphaColors.White;

  // Default Border Settings
  FBorderColor := $FF1E3A8A;  // Dark Blue Border
  FBorderWidth := 2.0;
  FRoundCorners := 8.0;
  FShowBorder := True;

  FAnimationState := asIdle;
  FAnimProgress := 1.0;
  FIsHovered := False;
  FIsPressed := False;
  FTime := 0;
  FMousePos := TPointF.Create(0,0);

  HitTest := True;
  SetBounds(0, 0, 140, 50);
  Redraw;
end;

destructor TSkiaButton.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TSkiaButton.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetButtonStyle(const Value: TButtonStyle);
begin
  if FButtonStyle <> Value then
  begin
    FButtonStyle := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetColor(const Value: TAlphaColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetHoverColor(const Value: TAlphaColor);
begin
  if FHoverColor <> Value then
  begin
    FHoverColor := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetPressedColor(const Value: TAlphaColor);
begin
  if FPressedColor <> Value then
  begin
    FPressedColor := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetTextColor(const Value: TAlphaColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetBorderColor(const Value: TAlphaColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetBorderWidth(const Value: Single);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetRoundCorners(const Value: Single);
begin
  if FRoundCorners <> Value then
  begin
    FRoundCorners := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    InvalidateBuffer;
  end;
end;

procedure TSkiaButton.SetHovered(const Value: Boolean);
begin
  if FIsHovered <> Value then
  begin
    FIsHovered := Value;
    if FIsHovered then
    begin
      if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
    end
    else
    begin
      if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
    end;
    InvalidateBuffer;
    UpdateState;
  end;
end;

procedure TSkiaButton.SetPressed(const Value: Boolean);
begin
  if FIsPressed <> Value then
  begin
    FIsPressed := Value;
    InvalidateBuffer;
    UpdateState;
  end;
end;

procedure TSkiaButton.UpdateState;
var
  IsIdle: Boolean;
begin
  IsIdle := (FAnimationState = asIdle) and not FIsHovered and not FIsPressed;

  if IsIdle then
    FTimer.Enabled := False
  else
    FTimer.Enabled := True;

  InvalidateRect(LocalRect);
end;

procedure TSkiaButton.InvalidateBuffer;
begin
  FBackBuffer := nil;
  Redraw;
end;

procedure TSkiaButton.OnTimer(Sender: TObject);
const
  Delta = 0.016;
begin
  FTime := FTime + Delta;

  if FAnimationState <> asIdle then
  begin
    FAnimProgress := FAnimProgress + Delta;
    if FAnimProgress >= 1.0 then
    begin
      FAnimProgress := 1.0;
      if FAnimationState = asHiding then
      begin
        Visible := False;
        FAnimationState := asIdle;
        UpdateState;
        Exit;
      end;
      FAnimationState := asIdle;
      UpdateState;
    end;
  end;

  Redraw;
end;

procedure TSkiaButton.ShowAnimated;
begin
  Visible := True;
  FAnimationState := asShowing;
  FAnimProgress := 0.0;
  InvalidateBuffer;
  UpdateState;
  Repaint;
end;

procedure TSkiaButton.HideAnimated;
begin
  if FAnimationState <> asHiding then
  begin
    FAnimationState := asHiding;
    FAnimProgress := 0.0;
    InvalidateBuffer;
    UpdateState;
  end;
end;

procedure TSkiaButton.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FMousePos := PointF(X, Y);
  if PtInRect(RectF(0, 0, Width, Height), FMousePos) then
    SetHovered(True)
  else
    SetHovered(False);
end;

procedure TSkiaButton.DoMouseLeave;
begin
  inherited;
  SetHovered(False);
end;

procedure TSkiaButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if Button = TMouseButton.mbLeft then
  begin
    SetPressed(True);
    if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TSkiaButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if Button = TMouseButton.mbLeft then
  begin
    SetPressed(False);
    if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
    if PtInRect(RectF(0, 0, Width, Height), PointF(X, Y)) then
      if Assigned(FOnClick) then FOnClick(Self);
  end;
end;

procedure TSkiaButton.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
begin
  inherited Draw(ACanvas, ADest, AOpacity);

  if not Assigned(FBackBuffer) or
     (FBackBuffer.Width <> Round(Width)) or
     (FBackBuffer.Height <> Round(Height)) or
     (FAnimationState <> asIdle) or
     FIsHovered or
     FIsPressed then
  begin
    RenderToBuffer(Round(Width), Round(Height));
  end;

  if Assigned(FBackBuffer) then
    ACanvas.DrawImage(FBackBuffer, 0, 0, TSkSamplingOptions.High)
  else
    ACanvas.Clear(TAlphaColors.Null);
end;

procedure TSkiaButton.RenderToBuffer(const AWidth, AHeight: Integer);
var
  Surface: ISkSurface;
  Canvas: ISkCanvas;
  DestRect: TRectF;
  Paint: ISkPaint;
  Font: ISkFont;
  Typeface: ISkTypeface;
  Opacity, Scale: Single;
  Center: TPointF;
  SaveCount: Integer;
  Pulse: Single;
  NormX, NormY: Single;
  TransType: TTransitionType;
  PathBuilder: ISkPathBuilder;
  ClipPath: ISkPath;
  RoundRect: ISkRoundRect;
begin
  if (AWidth <= 0) or (AHeight <= 0) then Exit;

  Surface := TSkSurface.MakeRaster(AWidth, AHeight);
  if not Assigned(Surface) then Exit;

  Canvas := Surface.Canvas;
  DestRect := RectF(0, 0, AWidth, AHeight);
  Canvas.Clear(TAlphaColors.Null);
  SaveCount := Canvas.Save;

  Opacity := 1.0;
  Scale := 1.0;

  // Determine which transition to use
  if FAnimationState = asHiding then
    TransType := FHideTransition
  else if FAnimationState = asShowing then
    TransType := FShowTransition
  else
    TransType := ttFade;

  // --- 1. Calculate Hover/Pressed Scales ---
  if FIsPressed then
    Scale := Scale * 0.95
  else if FIsHovered and (FHoverEffect = heScaleUp) then
    Scale := Scale * 1.05;

  // ========================================================================
  // FIX: We MUST apply the Hover Animations (Liquid/Tilt) BEFORE the Clip
  // ========================================================================

  // --- 2. Apply Hover Effects (Liquid & Tilt) ---
  if not (FAnimationState in [asShowing, asHiding]) then
  begin
    if FIsHovered and (FHoverEffect = heLiquid) then
    begin
      Pulse := Sin(FTime * 5) * 0.02;
      Scale := Scale + Pulse;
    end;

    if (Scale <> 1.0) or (FIsHovered and (FHoverEffect = heTilt)) then
    begin
      Center := PointF(AWidth / 2, AHeight / 2);
      Canvas.Translate(Center.X, Center.Y);
      Canvas.Scale(Scale, Scale);

      if FIsHovered and (FHoverEffect = heTilt) then
      begin
        NormX := ((FMousePos.X / AWidth) - 0.5) * 2;
        NormY := ((FMousePos.Y / AHeight) - 0.5) * 2;
        Canvas.Scale(1.0 - (NormX * 0.1), 1.0 - (NormY * 0.1));
        Canvas.Translate(NormX * 5, NormY * 5);
      end;

      Canvas.Translate(-Center.X, -Center.Y);
    end;
  end;

  // --- 3. Apply Global Transition Transforms ---
  if (FAnimationState = asShowing) or (FAnimationState = asHiding) then
  begin
    Canvas.RestoreToCount(SaveCount);
    SaveCount := Canvas.Save;

    case TransType of
      ttFade:
        Opacity := IfThen(FAnimationState = asHiding, 1.0 - FAnimProgress, FAnimProgress);

      ttImplode:
        begin
          if FAnimationState = asHiding then
            Scale := 1.0 - FAnimProgress
          else
            Scale := FAnimProgress;

          Center := PointF(AWidth / 2, AHeight / 2);
          Canvas.Translate(Center.X, Center.Y);
          Canvas.Scale(Scale, Scale);
          Canvas.Translate(-Center.X, -Center.Y);
        end;

      tsExplode:
        begin
          if FAnimationState = asHiding then
          begin
            Scale := 1.0 + (FAnimProgress * 0.5);
            Opacity := 1.0 - FAnimProgress;
          end
          else
          begin
            Scale := 1.5 - (FAnimProgress * 0.5);
          end;

          Center := PointF(AWidth / 2, AHeight / 2);
          Canvas.Translate(Center.X, Center.Y);
          Canvas.Scale(Scale, Scale);
          Canvas.Translate(-Center.X, -Center.Y);
        end;
    end;
  end;

  // --- 4. Clip to Rounded Rectangle ---
  if FRoundCorners > 0 then
  begin
    PathBuilder := TSkPathBuilder.Create;
    RoundRect := TSkRoundRect.Create;
    RoundRect.SetRect(DestRect, FRoundCorners, FRoundCorners);
    PathBuilder.AddRoundRect(RoundRect);
    ClipPath := PathBuilder.Detach;
    Canvas.ClipPath(ClipPath);
  end;

  if Opacity < 1.0 then
  begin
    Paint := TSkPaint.Create;
    Paint.AlphaF := Opacity;
    Canvas.SaveLayer(Paint);
  end;

  // --- 5. Draw Styles ---
  case FButtonStyle of
    bsFlat:    DrawFlatStyle(Canvas, DestRect, 1.0);
    bsNeon:    DrawNeonStyle(Canvas, DestRect, 1.0);
    bsRetro:   DrawRetroStyle(Canvas, DestRect, 1.0);
  end;

  // --- 6. Draw Border (If Enabled) ---
  if FShowBorder and (FBorderWidth > 0) then
  begin
    Paint := TSkPaint.Create;
    Paint.Style := TSkPaintStyle.Stroke;
    Paint.StrokeWidth := FBorderWidth;
    Paint.Color := FBorderColor;
    Paint.AntiAlias := True;
    Canvas.DrawRoundRect(DestRect, FRoundCorners, FRoundCorners, Paint);
  end;

  // --- 7. Draw Overlays ---
if FIsHovered and (FHoverEffect = heRipple) then
begin
  Pulse := (FTime * 0.5) - Floor(FTime * 0.5);

  // Simple per-cycle variation (changes when entering new ripple)
  var CycleSeed := Floor(FTime * 0.5);
  var BrightnessMul := 0.75 + 0.45 * (CycleSeed mod 7 / 7.0); // 0.75–1.2 range

  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Fill;
  Paint.Color := $FFFFFF;
  Paint.AlphaF := 0.48 * BrightnessMul * (1.0 - Pulse);

  Canvas.DrawCircle(PointF(AWidth/2, AHeight/2),
                    Pulse * (AWidth * 1.15),
                    Paint);
end;

  if FIsHovered and (FHoverEffect = heGlow) then
  begin
     Paint := TSkPaint.Create;
     Paint.Style := TSkPaintStyle.Stroke;
     Paint.StrokeWidth := 4;
     Paint.Color := $FFFFFF;
     Paint.AlphaF := 0.3 + (Sin(FTime * 3) * 0.1);
     Paint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Solid, 4);
     Canvas.DrawRoundRect(DestRect, FRoundCorners, FRoundCorners, Paint);
  end;

  if FIsHovered and (FHoverEffect = heSpot) then
  begin
    Paint := TSkPaint.Create;
    Paint.Style := TSkPaintStyle.Fill;
    Paint.Color := $AA000000;
    Canvas.DrawCircle(FMousePos, 40, Paint);
  end;

  // Text
  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Fill;
  Paint.Color := FTextColor;
  Paint.AntiAlias := True;
  Typeface := TSkTypeface.MakeDefault;
  Font := TSkFont.Create(Typeface, 20);
  DrawCenteredText(Canvas, FText, DestRect, Font, Paint);

  if Opacity < 1.0 then
    Canvas.Restore;

  Canvas.RestoreToCount(SaveCount);
  FBackBuffer := Surface.MakeImageSnapshot;
end;

procedure TSkiaButton.DrawCenteredText(const ACanvas: ISkCanvas; const AText: string; const ADest: TRectF; const AFont: ISkFont; const APaint: ISkPaint);
var
  TextBlob: ISkTextBlob;
  TextPos: TPointF;
  EstimatedWidth, EstimatedHeight: Single;
begin
  TextBlob := TSkTextBlob.MakeFromText(AText, AFont);
  if Length(AText) > 0 then
    EstimatedWidth := Length(AText) * (AFont.GetSize * 0.6)
  else
    EstimatedWidth := 0;
  EstimatedHeight := AFont.GetSize;
  TextPos.X := (ADest.Width - EstimatedWidth) / 2;
  TextPos.Y := (ADest.Height / 2) + (EstimatedHeight / 3);
  ACanvas.DrawTextBlob(TextBlob, TextPos.X, TextPos.Y, APaint);
end;

procedure TSkiaButton.DrawFlatStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
var
  Paint: ISkPaint;
  R: TRectF;
  PathEffect: ISkPathEffect;
begin
  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Fill;
  if FIsPressed then
    Paint.Color := FPressedColor
  else if FIsHovered then
    Paint.Color := FHoverColor
  else
    Paint.Color := FColor;

  Paint.AntiAlias := True;

  R := ARect;

  // For Flat style, we generally want to respect the border width by shrinking the background
  // so the border (if any) doesn't overlap it weirdly, OR we just fill the whole thing.
  // Given the ClipPath in RenderToBuffer handles the shape, we just fill the rect.
  // However, if BorderWidth is large, we might want to inset.
  // For simplicity, we fill the whole rect, border draws on top.

  if FIsHovered and (FHoverEffect = heLiquid) then
  begin
    ACanvas.DrawRoundRect(R, FRoundCorners, FRoundCorners, Paint);

    Paint.Style := TSkPaintStyle.Stroke;
    Paint.StrokeWidth := 2;
    Paint.Color := TAlphacolors.White;
    PathEffect := TSkPathEffect.MakeDiscrete(4.0 + Sin(FTime*5)*2, 2.0);
    Paint.PathEffect := PathEffect;
    ACanvas.DrawRoundRect(R, FRoundCorners, FRoundCorners, Paint);
  end
  else
  begin
    ACanvas.DrawRoundRect(R, FRoundCorners, FRoundCorners, Paint);
  end;
end;

procedure TSkiaButton.DrawNeonStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
var
  Paint: ISkPaint;
  R: TRectF;
begin
  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Fill;
  Paint.Color := $FF101010; // Dark background for Neon
  R := ARect;
  ACanvas.DrawRoundRect(R, FRoundCorners, FRoundCorners, Paint);

  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Stroke;
  Paint.StrokeWidth := 4;
  Paint.Color := IfThen(FIsHovered, FHoverColor, FColor);
  Paint.ImageFilter := TSkImageFilter.MakeBlur(8, 8);
  Paint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Normal, 5);
  ACanvas.DrawRoundRect(R, FRoundCorners, FRoundCorners, Paint);
end;

procedure TSkiaButton.DrawRetroStyle(const ACanvas: ISkCanvas; const ARect: TRectF; const AOpacity: Single);
var
  Paint: ISkPaint;
  R: TRectF;
  Lighter, Darker: TAlphaColor;
begin
  Paint := TSkPaint.Create;
  Paint.Style := TSkPaintStyle.Fill;
  Paint.Color := FColor;
  R := ARect;
  ACanvas.DrawRect(R, Paint);

  Paint.Style := TSkPaintStyle.Stroke;
  Paint.StrokeWidth := 4;

  Lighter := FHoverColor;
  Darker := FPressedColor;

  Paint.Color := Lighter;
  ACanvas.DrawLine(R.Left, R.Top, R.Right, R.Top, Paint);
  ACanvas.DrawLine(R.Left, R.Top, R.Left, R.Bottom, Paint);

  Paint.Color := Darker;
  ACanvas.DrawLine(R.Right, R.Top, R.Right, R.Bottom, Paint);
  ACanvas.DrawLine(R.Left, R.Bottom, R.Right, R.Bottom, Paint);
end;

end.
