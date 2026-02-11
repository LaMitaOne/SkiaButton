unit Unit9;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Effects,
  FMX.Colors, FMX.Edit, uSkiaButton;

type
  TForm9 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
    FSpawnBtn: TButton;
    FExplodeBtn: TButton;

    // Combos
    FStyleCombo: TComboBox;
    FTransitionCombo: TComboBox;
    FHoverCombo: TComboBox;

    // Appearance Controls
    FGroupAppearance: TGroupBox;
    FRadioBack: TRadioButton;
    FRadioBorder: TRadioButton;
    FRadioText: TRadioButton;
    FColorPanel: TColorPanel;
    FWidthLabel: TLabel;
    FWidthTrack: TTrackBar;
    FCheckBorder: TCheckBox;

    procedure DoSpawnClick(Sender: TObject);
    procedure DoExplodeClick(Sender: TObject);
    procedure SetupCombos;
    procedure SetupAppearanceControls;

    procedure DoLiveUpdate(Sender: TObject);
    procedure DoColorChange(Sender: TObject);
    procedure DoWidthChange(Sender: TObject);
    procedure DoBorderCheck(Sender: TObject);
  public
    { Public-Deklarationen }
  end;

var
  Form9: TForm9;

implementation
{$R *.fmx}

procedure TForm9.FormCreate(Sender: TObject);
begin
  // --- Top Control Bar ---

  FSpawnBtn := TButton.Create(Self);
  FSpawnBtn.Parent := Self;
  FSpawnBtn.Text := 'Spawn Buttons';
  FSpawnBtn.SetBounds(20, 20, 100, 30);
  FSpawnBtn.OnClick := DoSpawnClick;

  FExplodeBtn := TButton.Create(Self);
  FExplodeBtn.Parent := Self;
  FExplodeBtn.Text := 'Hide All';
  FExplodeBtn.SetBounds(130, 20, 80, 30);
  FExplodeBtn.OnClick := DoExplodeClick;

  SetupCombos;
  SetupAppearanceControls;
end;

procedure TForm9.SetupCombos;
begin
  // --- Style Combo ---
  FStyleCombo := TComboBox.Create(Self);
  FStyleCombo.Parent := Self;
  FStyleCombo.SetBounds(230, 20, 100, 30);
  FStyleCombo.Items.Add('Flat');
  FStyleCombo.Items.Add('Neon');
  FStyleCombo.Items.Add('Retro');
  FStyleCombo.ItemIndex := 0;
  FStyleCombo.OnChange := DoLiveUpdate;

  // --- Transition Combo ---
  FTransitionCombo := TComboBox.Create(Self);
  FTransitionCombo.Parent := Self;
  FTransitionCombo.SetBounds(340, 20, 100, 30);
  FTransitionCombo.Items.Add('Fade');
  FTransitionCombo.Items.Add('Implode');
  FTransitionCombo.Items.Add('Explode');
  FTransitionCombo.ItemIndex := 1;
  FTransitionCombo.OnChange := DoLiveUpdate;

  // --- Hover Effect Combo ---
  FHoverCombo := TComboBox.Create(Self);
  FHoverCombo.Parent := Self;
  FHoverCombo.SetBounds(450, 20, 120, 30);
  FHoverCombo.Items.Add('None');
  FHoverCombo.Items.Add('Glow');
  FHoverCombo.Items.Add('ScaleUp');
  FHoverCombo.Items.Add('Ripple');
  FHoverCombo.Items.Add('Liquid');
  FHoverCombo.Items.Add('Tilt');
  FHoverCombo.Items.Add('Spot');
  FHoverCombo.ItemIndex := 4;
  FHoverCombo.OnChange := DoLiveUpdate;
end;

procedure TForm9.SetupAppearanceControls;
begin
  // --- Appearance Group (Made Smaller) ---
  FGroupAppearance := TGroupBox.Create(Self);
  FGroupAppearance.Parent := Self;
  FGroupAppearance.Text := 'Appearance';
  FGroupAppearance.SetBounds(20, 60, 260, 120);
  FGroupAppearance.Padding.Rect := RectF(10, 20, 10, 10);

  // --- Radio Buttons: Target ---
  FRadioBack := TRadioButton.Create(Self);
  FRadioBack.Parent := FGroupAppearance;
  FRadioBack.Text := 'Background';
  FRadioBack.Position.X := 10;
  FRadioBack.Position.Y := 20;
  FRadioBack.IsChecked := True;
  FRadioBack.OnChange := DoLiveUpdate;

  FRadioBorder := TRadioButton.Create(Self);
  FRadioBorder.Parent := FGroupAppearance;
  FRadioBorder.Text := 'Border';
  FRadioBorder.Position.X := 100;
  FRadioBorder.Position.Y := 20;
  FRadioBorder.OnChange := DoLiveUpdate;

  FRadioText := TRadioButton.Create(Self);
  FRadioText.Parent := FGroupAppearance;
  FRadioText.Text := 'Text';
  FRadioText.Position.X := 170;
  FRadioText.Position.Y := 20;
  FRadioText.OnChange := DoLiveUpdate;

  // --- Color Picker (Moved Beside the Group) ---
  FColorPanel := TColorPanel.Create(Self);
  FColorPanel.Parent := Self;
  FColorPanel.Position.X := 290;
  FColorPanel.Position.Y := 60;
  FColorPanel.Color := $FF3B82F6;
  FColorPanel.OnChange := DoColorChange;

  // --- Border Width (Adjusted for narrower group) ---
  FWidthLabel := TLabel.Create(Self);
  FWidthLabel.Parent := FGroupAppearance;
  FWidthLabel.Text := 'Width: 2';
  FWidthLabel.Position.X := 10;
  FWidthLabel.Position.Y := 55;

  FWidthTrack := TTrackBar.Create(Self);
  FWidthTrack.Parent := FGroupAppearance;
  FWidthTrack.Position.X := 10;
  FWidthTrack.Position.Y := 75;
  FWidthTrack.Width := 160;
  FWidthTrack.Min := 0;
  FWidthTrack.Max := 10;
  FWidthTrack.Value := 2;
  FWidthTrack.OnChange := DoWidthChange;

  FCheckBorder := TCheckBox.Create(Self);
  FCheckBorder.Parent := FGroupAppearance;
  FCheckBorder.Text := 'Show Border';
  FCheckBorder.Position.X := 10;
  FCheckBorder.Position.Y := 95;
  FCheckBorder.IsChecked := True;
  FCheckBorder.OnChange := DoBorderCheck;
end;

procedure TForm9.DoLiveUpdate(Sender: TObject);
var
  I: Integer;
  Btn: TSkiaButton;
  SelectedStyle: TButtonStyle;
  SelectedTrans: TTransitionType;
  SelectedHover: THoverEffect;
begin
  // 1. Determine what was selected
  case FStyleCombo.ItemIndex of
    0:
      SelectedStyle := bsFlat;
    1:
      SelectedStyle := bsNeon;
    2:
      SelectedStyle := bsRetro;
  else
    SelectedStyle := bsFlat;
  end;

  case FTransitionCombo.ItemIndex of
    0:
      SelectedTrans := ttFade;
    1:
      SelectedTrans := ttImplode;
    2:
      SelectedTrans := tsExplode;
  else
    SelectedTrans := ttImplode;
  end;

  case FHoverCombo.ItemIndex of
    0:
      SelectedHover := heNone;
    1:
      SelectedHover := heGlow;
    2:
      SelectedHover := heScaleUp;
    3:
      SelectedHover := heRipple;
    4:
      SelectedHover := heLiquid;
    5:
      SelectedHover := heTilt;
    6:
      SelectedHover := heSpot;
  else
    SelectedHover := heGlow;
  end;

  // 2. Update all existing buttons immediately
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TSkiaButton then
    begin
      Btn := TSkiaButton(Components[I]);

      // Apply properties
      Btn.ButtonStyle := SelectedStyle;
      Btn.HoverEffect := SelectedHover;
      Btn.ShowTransition := SelectedTrans;
      Btn.HideTransition := SelectedTrans;
    end;
  end;
end;

procedure TForm9.DoColorChange(Sender: TObject);
var
  I: Integer;
  Btn: TSkiaButton;
  NewColor: TAlphaColor;
begin
  NewColor := FColorPanel.Color;

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TSkiaButton then
    begin
      Btn := TSkiaButton(Components[I]);

      if FRadioBack.IsChecked then
      begin
        Btn.Color := NewColor;
      end
      else if FRadioBorder.IsChecked then
      begin
        Btn.BorderColor := NewColor;
      end
      else if FRadioText.IsChecked then
      begin
        Btn.TextColor := NewColor;
      end;
    end;
  end;
end;

procedure TForm9.DoWidthChange(Sender: TObject);
var
  I: Integer;
  Btn: TSkiaButton;
  W: Single;
begin
  W := FWidthTrack.Value;
  FWidthLabel.Text := 'Width: ' + FloatToStr(W);

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TSkiaButton then
    begin
      Btn := TSkiaButton(Components[I]);
      Btn.BorderWidth := W;
    end;
  end;
end;

procedure TForm9.DoBorderCheck(Sender: TObject);
var
  I: Integer;
  Btn: TSkiaButton;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TSkiaButton then
    begin
      Btn := TSkiaButton(Components[I]);
      Btn.ShowBorder := FCheckBorder.IsChecked;
    end;
  end;
end;

procedure TForm9.DoSpawnClick(Sender: TObject);
var
  I, Col, Row: Integer;
  Btn: TSkiaButton;
  SelectedStyle: TButtonStyle;
  SelectedTrans: TTransitionType;
  SelectedHover: THoverEffect;
  CurrentColor: TAlphaColor;
const
  ButtonCount = 12;
  Cols = 4;
  Margin = 20;
  StartY = 220;
begin
  // Clean up old buttons
  for I := ComponentCount - 1 downto 0 do
  begin
    if Components[I] is TSkiaButton then
      Components[I].Free;
  end;

  // Read current Combo settings
  case FStyleCombo.ItemIndex of
    0:
      SelectedStyle := bsFlat;
    1:
      SelectedStyle := bsNeon;
    2:
      SelectedStyle := bsRetro;
  else
    SelectedStyle := bsFlat;
  end;

  case FTransitionCombo.ItemIndex of
    0:
      SelectedTrans := ttFade;
    1:
      SelectedTrans := ttImplode;
    2:
      SelectedTrans := tsExplode;
  else
    SelectedTrans := ttImplode;
  end;

  case FHoverCombo.ItemIndex of
    0:
      SelectedHover := heNone;
    1:
      SelectedHover := heGlow;
    2:
      SelectedHover := heScaleUp;
    3:
      SelectedHover := heRipple;
    4:
      SelectedHover := heLiquid;
    5:
      SelectedHover := heTilt;
    6:
      SelectedHover := heSpot;
  else
    SelectedHover := heGlow;
  end;

  // Get current color from Panel
  CurrentColor := FColorPanel.Color;

  // Create the Grid
  for I := 0 to ButtonCount - 1 do
  begin
    Btn := TSkiaButton.Create(Self);
    Btn.Parent := Self;

    Col := I mod Cols;
    Row := I div Cols;

    Btn.Width := 150;
    Btn.Height := 60;

    Btn.Position.X := Margin + (Col * (Btn.Width + Margin));
    Btn.Position.Y := StartY + (Row * (Btn.Height + Margin));

    Btn.Text := 'Button ' + IntToStr(I + 1);

    // Apply Appearance Defaults from Controls
    if FRadioBack.IsChecked then
      Btn.Color := CurrentColor
    else
      Btn.Color := $FF3B82F6;

    if FRadioBorder.IsChecked then
      Btn.BorderColor := CurrentColor
    else
      Btn.BorderColor := $FF1E3A8A;

    if FRadioText.IsChecked then
      Btn.TextColor := CurrentColor
    else
      Btn.TextColor := TAlphaColors.White;

    Btn.BorderWidth := FWidthTrack.Value;
    Btn.ShowBorder := FCheckBorder.IsChecked;

    Btn.ButtonStyle := SelectedStyle;
    Btn.ShowTransition := SelectedTrans;
    Btn.HideTransition := SelectedTrans;
    Btn.HoverEffect := SelectedHover;

    Btn.ShowAnimated;
  end;
end;

procedure TForm9.DoExplodeClick(Sender: TObject);
var
  I: Integer;
begin
  for I := ComponentCount - 1 downto 0 do
  begin
    if Components[I] is TSkiaButton then
    begin
      TSkiaButton(Components[I]).HideAnimated;
    end;
  end;
end;

end.

