unit configurator;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, Menus,
  utils;//,
  //tlib,twin,tstr;

type

  { TfmConfigurator }

  TfmConfigurator = class(TForm)
    Panel1: TPanel;
    cbTheme: TComboBox;
    Label1: TLabel;
    tbAlpha: TTrackBar;
    Label2: TLabel;
    rgBorder: TRadioGroup;
    Label3: TLabel;
    bbtCancel: TBitBtn;
    bbtOk: TBitBtn;
    procedure bbtOkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure initData();
  end;

{$i const.inc}

var
  fmConfigurator: TfmConfigurator;

implementation

{$R *.lfm}

uses main;

{ TfmConfigurator }

procedure TfmConfigurator.FormActivate(Sender: TObject);
begin

  initData();
end;


procedure TfmConfigurator.bbtOkClick(Sender: TObject);
begin

  MainForm.setTheme(cbTheme.Items[cbTheme.ItemIndex]);
  MainForm.setBorder(rgBorder.ItemIndex);
  MainForm.setAlpha(tbAlpha.Position);
end;


procedure TfmConfigurator.initData;
var lsFolder     : String;
    lsFullFolder : String;
begin

  //***** Читаем каталог с темами
  cbTheme.Items.Clear;
  lsFolder:=EasyFindFirst(g_sProgrammFolder+ccSlashChar+csThemesFolder);
  lsFullFolder:=g_sProgrammFolder+ccSlashChar+csThemesFolder+ccSlashChar+lsFolder;
  slashIt(lsFullFolder);
  if not isEmpty(lsFullFolder) then begin

    if FileExists(lsFullFolder+csOnBitImage) and
       FileExists(lsFullFolder+csOffBitImage) then begin

      cbTheme.Items.Add(lsFolder);
    end;
    while not isEmpty(lsFolder) do begin

      lsFolder:=EasyFindNext();
      lsFullFolder:=g_sProgrammFolder+ccSlashChar+csThemesFolder+ccSlashChar+lsFolder;
      slashIt(lsFullFolder);
      if FileExists(lsFullFolder+csOnBitImage) and
         FileExists(lsFullFolder+csOffBitImage) then begin

        cbTheme.Items.Add(ExtractFileName(lsFolder));
      end;
    end;
    EasyFindClose;
    cbTheme.ItemIndex:=cbTheme.Items.IndexOf(MainForm.getTheme());
  end;

  //***** Бордюр
  rgBorder.ItemIndex:=MainForm.getBorder();

  //***** Прозрачность
  tbAlpha.Position:=MainForm.getAlpha();
end;


end.
