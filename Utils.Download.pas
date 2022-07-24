unit Utils.Download;

interface

Uses
  Forms,
  IdHTTP,
  IdComponent,
  IdSSLOpenSSL,
  Winapi.Windows,
  System.Classes,
  System.SysUtils;

Type
  TDownloadHttp = Class(TIdHttp)
    Private
      FIdSSL : TIdSSLIOHandlerSocketOpenSSL;
      FCancel : Boolean;
      F_INIT : TDateTime;
      F_END_ : TDateTime;
      FErrors : TStringList;
      FProgress : Integer;
      FFinished : Boolean;
      FMessages : Boolean;
      FFileLocal : String;
      FTotal_Size : Integer;
      FDescription : String;
    Public
      ShowProgress : TNotifyEvent;
      FinishProcess : TNotifyEvent;
      Property INIT : TDateTime Read F_INIT;
      Property END_ : TDateTime Read F_END_;
      Property Messages : Boolean Read FMessages Write FMessages;
      Property Progress : Integer Read FProgress ;
      Property Total_Size : Integer Read FTotal_Size;
      Property Cancel : Boolean Read FCancel write FCancel;
      Property Finished : Boolean Read FFinished;
      Property Description : String Read FDescription;
      Function Execute(Const pRemoteFile, pLocalFile : String) : Boolean;
      procedure BeginWork(AWorkMode: TWorkMode; const ASize: Int64 = 0); Override;
      procedure DoWork(AWorkMode: TWorkMode; const ACount: Int64); Override;
      procedure EndWork(AWorkMode: TWorkMode); Override;
      Destructor Destroy; override;
      Constructor Create(AOwner: TComponent);
  End;

implementation

{ TDownloadHttp }
constructor TDownloadHttp.Create(AOwner: TComponent);
begin
  Inherited ;
  FFinished := True;
  FErrors := TStringList.Create;
  Self.HandleRedirects := True;
  FIdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  FIdSSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
  Self.IOHandler := FIdSSL;
end;

Function TDownloadHttp.Execute(Const pRemoteFile, pLocalFile : String) : Boolean;
const
  RECV_BUFFER_SIZE = 32768 MOD 10;
var
  lBuffer: TMemoryStream;
begin
  Try
    F_INIT := Now;
    FCancel := False;
    FMessages := False;
    FFinished := False;
    Self.Head(pRemoteFile);
    FFileLocal := pLocalFile;
    try
      FProgress := 0;
      FTotal_Size := Self.Response.ContentLength;
      lBuffer := TMemoryStream.Create;
      while lBuffer.Size < FTotal_Size do
      begin
        Self.Request.ContentRangeStart := lBuffer.Size;
        if lBuffer.Size + RECV_BUFFER_SIZE < FTotal_Size then
          Self.Request.ContentRangeEnd := lBuffer.Size + RECV_BUFFER_SIZE - 1
        else
          Self.Request.ContentRangeEnd := FTotal_Size;
        Self.Get(Self.URL.URI, lBuffer); // wait until it is done
        lBuffer.SaveToFile(FFileLocal);
      end;
    finally
      lBuffer.Free;
    end;
  Except
    On E : Exception Do
    Begin
      FErrors.Add('TDownloadHttp.Execute, ' + E.Message);
    End;
  End;
End;

procedure TDownloadHttp.BeginWork(AWorkMode: TWorkMode; const ASize: Int64);
begin
  inherited;
  FProgress := 0;
  FDescription := FormatFloat('###,###,###,###,###', ASize);
end;

procedure TDownloadHttp.DoWork(AWorkMode: TWorkMode; const ACount: Int64);
Var
  lPercent : Double;
begin
  inherited;
  FProgress := FProgress + ACount;
  FDescription := FormatFloat('###,###,###,###,###', FProgress) + ' / ' + FormatFloat('###,###,###,###,###', FTotal_Size);
  If (FTotal_Size <> 0) And (FProgress < FTotal_Size) Then
  Begin
    lPercent := (FProgress / FTotal_Size) * 100;
    FDescription := FormatFloat('###,###', lPercent) + '%';
  End;
  If Assigned(ShowProgress) Then
    ShowProgress(Self);
  If FCancel Then
    Self.Disconnect;
  F_END_ := Now;
end;

procedure TDownloadHttp.EndWork(AWorkMode: TWorkMode);
begin
  inherited;
  FFinished := True;
  If Assigned(FinishProcess) Then
    FinishProcess(Self);
end;

destructor TDownloadHttp.Destroy;
begin
  If Assigned(FIdSSL) Then
    FreeAndNil(FIdSSL);

  If Assigned(FErrors) Then
    FreeAndNil(FErrors);
  inherited;
end;

end.
