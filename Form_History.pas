unit Form_History;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids;

type
  TFrHistory = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
Procedure Form_History_Show;

implementation
{$R *.dfm}
Uses
  Utils.Connection;

procedure TFrHistory.FormCreate(Sender: TObject);
begin
  Try
    gConnexionSQLite.QRY.Active := False;
    gConnexionSQLite.QRY.SQL.Clear;
    gConnexionSQLite.QRY.SQL.Add(' SELECT * FROM ' + gConnexionSQLite.Const_Table);
    gConnexionSQLite.QRY.Active := True;
    DataSource1.DataSet := gConnexionSQLite.QRY;
  Except
    On E: Exception Do
      ShowMessage(e.Message);
  End;
end;

procedure TFrHistory.FormDestroy(Sender: TObject);
begin
  gConnexionSQLite.QRY.Active := False;
  gConnexionSQLite.QRY.SQL.Clear;
end;

Procedure Form_History_Show;
var
  FrHistory: TFrHistory;
Begin
  FrHistory := TFrHistory.Create(Nil);
  FrHistory.ShowModal;
  FreeAndNil(FrHistory);
End;

end.
