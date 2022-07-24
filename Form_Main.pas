unit Form_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Buttons, Utils.Download, Vcl.ExtCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFrMain = class(TForm)
    BTNSTART: TSpeedButton;
    BTNMSG: TSpeedButton;
    BTNSTOP: TSpeedButton;
    URL: TEdit;
    Label1: TLabel;
    LOCAL_FILE: TEdit;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    lbMessage: TListBox;
    BTNHISTORY: TSpeedButton;
    procedure BTNSTARTClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BTNSTOPClick(Sender: TObject);
    procedure BTNMSGClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BTNHISTORYClick(Sender: TObject);
  private
    { Private declarations }
    FDH : TDownloadHttp;
    Function YesNo(pCadena : String) : Boolean;
    Procedure ShowProgress(Sender: TObject);
    Procedure FinishProcess(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FrMain: TFrMain;

implementation
{$R *.dfm}
Uses
  Form_History,
  System.Threading,
  Utils.Connection;

Function MessageDlgCheck(pMsg : string; pType : TMsgDlgType; pButtons : TMsgDlgButtons; pIndiceHelp : LongInt; pDefButton : TModalResult; pCheckBox: Boolean; pMsgCheck: string; pFunction: TProcedure): Word;
Var
  lI: Integer;
  lForma: TForm;
  lCheck: TCheckBox;
Begin
  lCheck := Nil;
  lForma := CreateMessageDialog(pMsg, pType, pButtons);
  lForma.HelpContext := pIndiceHelp;
  For lI := 0 To lForma.ComponentCount - 1 Do
  Begin
    If (lForma.Components[lI] is TButton) Then
    Begin
      If (TButton(lForma.Components[lI]).ModalResult = pDefButton) Then
      Begin
        lForma.ActiveControl := TWincontrol(lForma.Components[lI]);
      End;
    End;
    If True Then
    Begin
      If pType = mtConfirmation Then
        lForma.Caption := 'Confirmación'
      Else
        If pType = mtWarning Then
          lForma.Caption := 'Aviso'
        Else
          If pType = mtError Then
            lForma.Caption := 'Error'
          Else
            If pType = mtInformation Then
              lForma.Caption := 'Información';
    End;
  End;
  If True Then
  Begin
    TButton(lForma.FindComponent('YES')).Caption    := '&Sí';
    TButton(lForma.FindComponent('NO')).Caption     := '&No';
    TButton(lForma.FindComponent('OK')).Caption     := '&Aceptar';
    TButton(lForma.FindComponent('CANCEL')).Caption := '&Cancelar';
    TButton(lForma.FindComponent('ABORT')).Caption  := '&Abortar';
    TButton(lForma.FindComponent('RETRY')).Caption  := '&Repetir';
    TButton(lForma.FindComponent('IGNORE')).Caption := '&Ignorar';
    TButton(lForma.FindComponent('ALL')).Caption    := '&Todos';
    TButton(lForma.FindComponent('HELP')).Caption   := 'A&yuda';
  End;
  If pCheckBox Then
  Begin
    lForma.ClientHeight := lForma.ClientHeight + 20;
    lCheck := TCheckBox.Create(lForma);
    lCheck.Parent := lForma;
    lCheck.Left := 15;
    lCheck.Top := lForma.ClientHeight - 20;
    lCheck.Visible := True;
    lCheck.Caption := pMsgCheck;
    lCheck.Width := lForma.ClientWidth - 10;
  End;
  Result := lForma.ShowModal;
  If Assigned(lCheck) Then
    If lCheck.Checked then
      If Assigned(pFunction) Then
         pFunction;
  lForma.Free;
End;

Function TFrMain.YesNo(pCadena : String) : Boolean;
Begin
    Result := MessageDlgCheck(pCadena, mtConfirmation, [mbYes, mbNo], 0, mrYes, False, '', Nil) = mrYes;
End;


Procedure TFrMain.ShowProgress(Sender: TObject);
Begin
  If Sender Is TDownloadHttp Then
  Begin
    ProgressBar1.Min := 0;
    ProgressBar1.Max := (Sender As TDownloadHttp).Total_Size;
    ProgressBar1.Position := (Sender As TDownloadHttp).Progress;
    If (Sender As TDownloadHttp).Messages Then
    Begin
      lbMessage.Items.Add((Sender As TDownloadHttp).Description);
      If lbMessage.Items.Count > 500 Then
        lbMessage.Items.Delete(0);
      lbMessage.ItemIndex := lbMessage.Items.Count - 1;
    End;
    ProgressBar1.Repaint;
  End;
End;

procedure TFrMain.BTNSTOPClick(Sender: TObject);
begin
  If Assigned(FDH) Then
    FDH.Cancel := True;
end;

Procedure TFrMain.FinishProcess(Sender: TObject);
Begin
  BTNSTART.Enabled   := True;
  BTNMSG.Enabled     := False;
  BTNSTOP.Enabled    := False;
  BTNHISTORY.Enabled := True ;
  ProgressBar1.Min := 0;
  ProgressBar1.Position := 0;
  If Sender Is TDownloadHttp Then
    gConnexionSQLite.Insert_LogDownload(Trim(URL.Text), (Sender As TDownloadHttp).INIT, (Sender As TDownloadHttp).END_);
End;

procedure TFrMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If Assigned(FDH) Then
    If Not FDH.Finished Then
    Begin
      CanClose := YesNo('Existe um download em andamento, deseja interrompe-lo?');
      If CanClose Then
      Begin
        FDH.Disconnect;
        FDH := Nil;
      End;
    End;
end;

procedure TFrMain.FormCreate(Sender: TObject);
begin
  FDH := TDownloadHttp.Create(Nil);
  FDH.ShowProgress := ShowProgress;
  FDH.FinishProcess := FinishProcess;
  FinishProcess(Nil);
end;

procedure TFrMain.FormDestroy(Sender: TObject);
begin
  If Assigned(FDH) Then
    FreeAndNil(FDH);
end;

procedure TFrMain.BTNHISTORYClick(Sender: TObject);
begin
  Form_History_Show;
end;

procedure TFrMain.BTNMSGClick(Sender: TObject);
begin
  If Assigned(FDH) Then
    FDH.Messages := Not FDH.Messages;
end;

procedure TFrMain.BTNSTARTClick(Sender: TObject);
Var
  lTask : ITask;
begin
  BTNSTART.Enabled   := False;
  BTNHISTORY.Enabled := False;
  BTNMSG.Enabled     := True ;
  BTNSTOP.Enabled    := True ;
  lbMessage.Items.Clear;
  lTask := TTask.Create (procedure
                         begin
                           If Assigned(FDH) Then
                             FDH.Execute(Trim(URL.Text), Trim(LOCAL_FILE.Text));
                         end);
  lTask.Start;
end;

end.
