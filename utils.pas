unit utils;

{$mode delphi}

interface

uses
  Classes, SysUtils, IniFiles;

const
  ccSlash      = '/';
  ccBackSlash  = '\';
  {$ifdef __LINUX__}
  ccSlashChar  = ccSlash;
  {$else}
  ccSlashChar  = ccBackSlash;
  {$endif}

type
  {$ifdef __LAZARUS__}
  uString = WideString;
  {$else}
  uString = String;
  {$endif}

function  IniOpen(psName : String) : Boolean;
function  IniReadInt(psSection,psName : String;piDefault : Integer = 0) : Integer;
function  IniReadString(psSection,psName : String; psDefaultStr : String = '') : String;
procedure IniWriteInt(psSection,psName : String; piValue : Integer);
procedure IniWriteString(psSection,psName,psLine : String);
procedure IniClose;
function EasyFindFirst(psFolder : String; psMask : String = '*.*'; piAttr : Integer = faAnyFile) : String;
function EasyFindNext : String;
function EasyFindClose : Boolean;
function slashIt(var psLine : String; pcSlash : Char = ccSlashChar) : String;
function IsIOError : Boolean;
function isEmpty(psLine : String) : Boolean;
function uLength(S : String): Integer;
function uTrim(const s: string): string;


var g_sProgrammFolder : String;


implementation

var ublFileOpened : Boolean = False;
    loXIniFile : TIniFile;
    uoEasySearchRec : TSearchRec;
    ublEasySearchOpen : Boolean = False;

function IniOpen(psName : String) : Boolean;
begin

  Result:=False;
  if not ublFileOpened then begin

    loXIniFile:=TIniFile.Create(psName);
    ublFileOpened:=True;
    Result:=True;
  end;
end;


procedure IniWriteString(psSection, psName, psLine : String);
begin

  if ublFileOpened then
    loXIniFile.WriteString(psSection,psName,psLine);
end;


procedure IniWriteInt(psSection, psName : String; piValue : Integer);
begin

  if ublFileOpened then
    loXIniFile.WriteInteger(psSection,psName,piValue);
end;


function IniReadString(psSection, psName : String; psDefaultStr : String = '') : String;
begin

  Result:=psDefaultStr;
  if ublFileOpened then
    Result:=loXIniFile.ReadString(psSection,psName,psDefaultStr);
end;


function IniReadInt(psSection, psName : String; piDefault : Integer = 0) : Integer;
begin

  Result:=piDefault;
  if ublFileOpened then
    Result:=loXIniFile.ReadInteger(psSection,psName,piDefault);
end;


procedure IniClose;
begin

  if ublFileOpened then begin

    FreeAndNil(loXIniFile);
    ublFileOpened:=False;
  end;
end;


function EasyFindFirst(psFolder : String; psMask : String = '*.*'; piAttr : Integer = faAnyFile) : String;
var lsFilename : String;
begin

  EasyFindFirst:='';
  if not ublEasySearchOpen then begin

    SlashIt(psFolder);
    if FindFirst(psFolder+psMask,piAttr,uoEasySearchRec)=0 then begin

      lsFileName:=uoEasySearchRec.Name;
      ublEasySearchOpen:=True;
      while (lsFileName='.') or (lsFileName='..') do begin

        lsFileName:=EasyFindNext;
      end;

      if not IsIOError then begin

        EasyFindFirst:=lsFileName;
      end;
    end;
  end;
end;


function EasyFindNext : String;
begin

  EasyFindNext:='';
  if ublEasySearchOpen then begin

    if FindNext(uoEasySearchRec)=0 then begin

      if not IsIOError then begin

        EasyFindNext:=uoEasySearchRec.Name;
      end;
    end;
  end;
end;


function EasyFindClose : Boolean;
begin

  EasyFindClose:=True;
  if ublEasySearchOpen then begin

    SysUtils.FindClose(uoEasySearchRec);
    if not IsIOError then begin

      EasyFindClose:=True;
      ublEasySearchOpen:=False;
    end;
  end;
end;


function slashIt(var psLine : String; pcSlash : Char = ccSlashChar) : String;
begin

  if not IsEmpty(psLine) then begin

    if psLine[Length(psLine)]<>pcSlash then
      psLine:=psLine+pcSlash;

  end;
  Result:=psLine;
end;


function IsIOError : Boolean;
begin

  IsIOError:=IOResult<>0;
end;


function isEmpty(psLine : String) : Boolean;
begin

  Result:=uLength(uTrim(psLine))=0;
end;


function uLength(S : String): Integer;
begin

  {$ifdef __LAZARUS__}
  Result:=UTF8Length(S);
  {$else}
  Result:=Length(S);
  {$endif}
end;


function uTrim(const s: string): string;
begin

  {$ifdef __LAZARUS__}
  Result:=UTF8Trim(S);
  {$else}
  Result:=Trim(S);
  {$endif}
end;

begin
  {$ifdef __LAZARUS__}
    g_sProgrammFolder:=ExtractFileDir(Application.Exename);
  {$else}
    g_sProgrammFolder:=ExtractFileDir(ParamStr(0));
  {$endif}
end.

