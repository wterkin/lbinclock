unit main;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DateUtils, StdCtrls, Menus,
  configurator,utils;
  {tlib,tcfg;}

type

  { TfmBinaryClock }

  TfmBinaryClock = class(TForm)
    imH20: TImage;
    imH10: TImage;
    imH8: TImage;
    imH4: TImage;
    imH2: TImage;
    imH1: TImage;
    imM80: TImage;
    imM40: TImage;
    imM10: TImage;
    imM20: TImage;
    imM8: TImage;
    imM4: TImage;
    imM2: TImage;
    imM1: TImage;
    clocktimer: TTimer;
    imS80: TImage;
    imS40: TImage;
    imS10: TImage;
    imS20: TImage;
    ims8: TImage;
    ims4: TImage;
    ims2: TImage;
    imS1: TImage;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    pmTrayMenu: TPopupMenu;
    TrayIcon1: TTrayIcon;
    procedure FormActivate(Sender: TObject);
    procedure clocktimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormClose(Sender: TObject; var {%H-}Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
  private
    { Private declarations }
    moBitOn        : TBitmap;
    moBitOff       : TBitmap;
    mdtTime        : TDateTime;
    mwHours,
    mwTensHours,
    mwMinutes,
    mwTensMinutes,
    mwSeconds,
    mwTensSeconds  : Word;

    //***** Конфиг
    msThemeName    : String;
    mbtAlphaValue  : Byte;
    miBorderStyle  : Integer;

    procedure SaveConfig();
    procedure LoadConfig();
    procedure ApplyConfig();
  public
    procedure WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING); message WM_WINDOWPOSCHANGING;
    { Public declarations }
    procedure InitLeds();
    procedure DecodeTimeToHMS();
    procedure Display();
    //procedure BitOn(poImage : TImage);
    //procedure BitOff(poImage : TImage);
    //procedure BitExactlyOff(poImage : TImage);
    function  getTheme() : String;
    function  getBorder() :Integer;
    function  getAlpha() : Byte;
    procedure setTheme(psThemeName : String);
    procedure setBorder(piBorderStyle : Integer);
    procedure setAlpha(pbtAlpha : Byte);
    procedure switchBit(poImage : TImage; pblCondition : Boolean);
  end;

{$i const.inc}

var
  fmBinaryClock: TfmBinaryClock;
  MainForm : TfmBinaryClock;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TfmBinaryClock.switchBit(poImage : TImage; pblCondition : Boolean);
begin

  if pblCondition then
  begin

    if poImage.Tag=0 then
    begin

      poImage.Picture.Bitmap.Assign(moBitOn);
      poImage.Tag:=1;
    end;
  end else
  begin

    if poImage.Tag>0 then
    begin

      poImage.Picture.Bitmap.Assign(moBitOff);
      poImage.Tag:=0;
    end;
	end;
end;
//
//procedure TfmBinaryClock.BitOff(poImage : TImage);
//begin
//
//  if poImage.Tag>0 then
//  begin
//
//    poImage.Picture.Bitmap.Assign(moBitOff);
//    poImage.Tag:=0;
//  end;
//end;
//
//
//procedure TfmBinaryClock.BitExactlyOff(poImage : TImage);
//begin
//
//  poImage.Picture.Bitmap.Assign(moBitOff);
//  poImage.Tag:=0;
//end;


function TfmBinaryClock.getTheme : String;
begin

  Result:=msThemeName;
end;


function TfmBinaryClock.getBorder : Integer;
begin

  Result:=miBorderStyle;
end;


function TfmBinaryClock.getAlpha: Byte;
begin

  Result:=mbtAlphaValue;
end;


procedure TfmBinaryClock.setTheme(psThemeName : String);
begin

  msThemeName:=psThemeName;
end;


procedure TfmBinaryClock.setBorder(piBorderStyle : Integer);
begin

  miBorderStyle:=piBorderStyle;
end;


procedure TfmBinaryClock.setAlpha(pbtAlpha : Byte);
begin

  mbtAlphaValue:=pbtAlpha;
end;


procedure TfmBinaryClock.SaveConfig;
begin

  IniOpen(g_sProgrammFolder+ccSlashChar+csConfigFile);

  //**** Тема
  IniWriteString('MAIN','THEME',msThemeName);

  //***** Обрамление окна
  IniWriteInt('MAIN','BORDERSTYLE',miBorderStyle);

  //***** Прозрачность
  IniWriteInt('MAIN','ALPHA',mbtAlphaValue);

  //**** Позиция окна
  IniWriteInt('MAIN','TOP',Top);
  IniWriteInt('MAIN','LEFT',Left);
  IniClose;
end;


procedure TfmBinaryClock.LoadConfig;
begin

  IniOpen(g_sProgrammFolder+ccSlashChar+csConfigFile);
  msThemeName:=IniReadString('MAIN','THEME','cyan');
  miBorderStyle:=IniReadInt('MAIN','BORDER',ciDialogBorder);
  mbtAlphaValue:=Byte(IniReadInt('MAIN','ALPHA',255));
  IniClose;
end;


procedure TfmBinaryClock.ApplyConfig;
begin

  //***** Устанавливаем выбранную тему.
  FreeAndNil(moBitOn);
  moBitOn:=TBitmap.Create;
  moBitOn.LoadFromFile(g_sProgrammFolder+ccSlashChar+
                       csThemesFolder+ccSlashChar+
                       msThemeName+ccSlashChar+
                       csOnBitImage);
  FreeAndNil(moBitOff);
  moBitOff:=TBitmap.Create;
  moBitOff.LoadFromFile(g_sProgrammFolder+ccSlashChar+
                        csThemesFolder+ccSlashChar+
                        msThemeName+ccSlashChar+
                        csOffBitImage);

  //***** Устанавливаем обрамление
  case miBorderStyle of
    ciNoneBorder: begin

      fmBinaryClock.BorderStyle:=bsNone;
      Height:=64;
    end;
    ciDialogBorder: BorderStyle:=bsDialog;
    ciThinBorder: BorderStyle:=bsToolWindow;
    else BorderStyle:=bsDialog;
  end;

  //***** Установим прозрачность
  fmBinaryClock.AlphaBlend:=(mbtAlphaValue<255);
  fmBinaryClock.AlphaBlendValue:=mbtAlphaValue;
  InitLeds;
end;


//procedure TfmBinaryClock.BitOn(poImage : TImage);
//begin
//
//  if poImage.Tag=0 then
//  begin
//
//    poImage.Picture.Bitmap.Assign(moBitOn);
//    poImage.Tag:=1;
//  end;
//end;
//

procedure TfmBinaryClock.clocktimerTimer(Sender: TObject);
begin

  DecodeTimeToHMS;
  Display;
end;


procedure TfmBinaryClock.DecodeTimeToHMS();
begin

  mdtTime:=Now;
  mwTensHours:=HourOf(mdtTime) div 10;
  mwHours:=HourOf(mdtTime) mod 10;
  mwTensMinutes:=MinuteOf(mdtTime) div 10;
  mwMinutes:=MinuteOf(mdtTime) mod 10;
  mwTensSeconds:=SecondOf(mdtTime) div 10;
  mwSeconds:=SecondOf(mdtTime) mod 10;
end;


procedure TfmBinaryClock.Display();
begin

  {---< Десятки часов >---}
  //if mwTensHours and 1=1 then BitOn(imH10) else BitOff(imH10);
  switchBit(imH10, mwTensHours and 1=1);
  //if mwTensHours and 2=2 then BitOn(imH20) else BitOff(imH20);
  switchBit(imH20, mwTensHours and 2=2);

  {---< Часы >---}
  //if mwHours and 1=1 then BitOn(imH1) else BitOff(imH1);
  switchBit(imH1, mwHours and 1=1);

  //if mwHours and 2=2 then BitOn(imH2) else BitOff(imH2);
  switchBit(imH2, mwHours and 2=2);

  //if mwHours and 4=4 then BitOn(imH4) else BitOff(imH4);
  switchBit(imH4, mwHours and 4=4);
  //if mwHours and 8=8 then BitOn(imH8) else BitOff(imH8);
  switchBit(imH8, mwHours and 8=8);

  {---< Десятки минут >---}
  //if mwTensMinutes and 1=1 then BitOn(imM10) else BitOff(imM10);
  switchBit(imM10, mwTensMinutes and 1=1);
  //if mwTensMinutes and 2=2 then BitOn(imM20) else BitOff(imM20);
  switchBit(imM20, mwTensMinutes and 2=2);
  //if mwTensMinutes and 4=4 then BitOn(imM40) else BitOff(imM40);
  switchBit(imM40, mwTensMinutes and 4=4);
  //if mwTensMinutes and 8=8 then BitOn(imM80) else BitOff(imM80);
  switchBit(imM80, mwTensMinutes and 8=8);

  {---< Минуты >---}
  //if mwMinutes and 1=1 then BitOn(imM1) else BitOff(imM1);
  switchBit(imM1, mwMinutes and 1=1);
  //if mwMinutes and 2=2 then BitOn(imM2) else BitOff(imM2);
  switchBit(imM2, mwMinutes and 2=2);
  //if mwMinutes and 4=4 then BitOn(imM4) else BitOff(imM4);
  switchBit(imM4, mwMinutes and 4=4);
  //if mwMinutes and 8=8 then BitOn(imM8) else BitOff(imM8);
  switchBit(imM8, mwMinutes and 8=8);

  {---< Десятки секунд >---}
  //if mwTensSeconds and 1=1 then BitOn(imS10) else BitOff(imS10);
  switchBit(imS10, mwTensSeconds and 1=1);
  //if mwTensSeconds and 2=2 then BitOn(imS20) else BitOff(imS20);
  switchBit(imS20, mwTensSeconds and 2=2);
  //if mwTensSeconds and 4=4 then BitOn(imS40) else BitOff(imS40);
  switchBit(imS40, mwTensSeconds and 4=4);
  //if mwTensSeconds and 8=8 then BitOn(imS80) else BitOff(imS80);
  switchBit(imS80, mwTensSeconds and 8=8);

  {---< Секунды >---}
  //if mwSeconds and 1=1 then BitOn(imS1) else BitOff(imS1);
  switchBit(imS1, mwSeconds and 1=1);
  //if mwSeconds and 2=2 then BitOn(imS2) else BitOff(imS2);
  switchBit(imS2, mwSeconds and 2=2);
  //if mwSeconds and 4=4 then BitOn(imS4) else BitOff(imS4);
  switchBit(imS4, mwSeconds and 4=4);
  //if mwSeconds and 8=8 then BitOn(imS8) else BitOff(imS8);
  switchBit(imS8, mwSeconds and 8=8);
end;


procedure TfmBinaryClock.FormActivate(Sender: TObject);
begin

  MainForm:=fmBinaryClock;
  loadConfig();
  applyConfig();
  DecodeTimeToHMS();
  Display();
end;


procedure TfmBinaryClock.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  SaveConfig();
  inherited;
end;


procedure TfmBinaryClock.FormCreate(Sender: TObject);
begin

  inherited;
  IniOpen(g_sProgrammFolder+ccSlashChar+csConfigFile);
  Top:=IniReadInt('MAIN','TOP',0);
  Left:=IniReadInt('MAIN','LEFT',0);
  IniClose;
end;


procedure TfmBinaryClock.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Key=vk_Escape then
  begin

    Close;
	end;

  if Key=vk_F4 then
  begin

    if fmConfigurator.ShowModal=mrOk then
    begin

      ApplyConfig();
		end;
	end;
end;


procedure TfmBinaryClock.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  const SC_DRAGMOVE : Longint = $F013;
begin

  if Button <> mbRight then
  begin

    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;


procedure TfmBinaryClock.InitLeds;
begin

  switchBit(imH20, False);
  switchBit(imH10, False);
  switchBit(imH8, False);
  switchBit(imH4, False);
  switchBit(imH2, False);
  switchBit(imH1, False);
  switchBit(imM80, False);
  switchBit(imM40, False);
  switchBit(imM20, False);
  switchBit(imM10, False);
  switchBit(imM8, False);
  switchBit(imM4, False);
  switchBit(imM2, False);
  switchBit(imM1, False);
  switchBit(imS80, False);
  switchBit(imS40, False);
  switchBit(imS20, False);
  switchBit(imS10, False);
  switchBit(imS8, False);
  switchBit(imS4, False);
  switchBit(imS2, False);
  switchBit(imS1, False);
end;


procedure TfmBinaryClock.WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING);
var WorkArea: TRect;
    StickAt : Word;
begin

  StickAt := 6;
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  with WorkArea, Msg.WindowPos^ do
  begin

    // Сдвигаем границы для сравнения с левой и верхней сторонами
	  Right:=Right-cx;
	  Bottom:=Bottom-cy;
	  if abs(Left - x) <= StickAt then
    begin

	    x := Left;
		end;
		if abs(Right - x) <= StickAt then
    begin

	    x := Right;
		end;
		if abs(Top - y) <= StickAt then
    begin

	    y := Top;
		end;
		if abs(Bottom - y) <= StickAt then
    begin

	    y := Bottom;
		end;
	end;
  inherited;
end;

end.
