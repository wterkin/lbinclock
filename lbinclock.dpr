program lbinclock;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  main in 'main.pas' {Form2},
  configurator in 'configurator.pas' {Form1};

{$R *.res}


begin
  Application.Initialize;
  Application.CreateForm(TfmBinaryClock, fmBinaryClock);
  Application.CreateForm(TfmConfigurator, fmConfigurator);
  Application.Run;
end.
