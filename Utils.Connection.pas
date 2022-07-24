unit Utils.Connection;

interface

Uses
  System.Classes, System.SysUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.DApt;

Type
  TConnexionSQLite = Class(TFDConnection)
    Protected
    Private
      FQRY : TFDQuery;
      Function MaxId(Var pResult : Integer) : Boolean;
      Function Validate_Table : Boolean;
    Public
      Last_Error : String;
      Const Const_Table = 'LOGDOWNLOAD';
      Property QRY : TFDQuery Read FQRY Write FQRY;
      Constructor Create(AOwner : TComponent); Override;
      Function Insert_LogDownload(Const pUrl : String; pDateInit, pDateEnd : TDateTime) : Boolean;
      Destructor Destroy; Override;
  End;

Var
 gConnexionSQLite : TConnexionSQLite;

implementation

{ TCOnnexionSQLite }
constructor TConnexionSQLite.Create(AOwner: TComponent);
begin
  inherited;
  Self.Params.Add('DriverID=SQLite');
  Self.Params.Add('Database=' + ChangeFileExt(GetModuleName(HInstance), '.sqlite'));
  Self.Params.Add('LockingMode=Normal');
  Self.Params.Add('Synchronous=Normal');
  FQRY := TFDQuery.Create(Nil);
  FQRY.Connection := Self;
  Validate_Table;
end;

destructor TConnexionSQLite.Destroy;
begin
  If Assigned(FQRY) Then
  Begin
    FQRY.Active := False;
    FreeAndNil(FQRY);
  End;
  If Self.Connected Then
    Self.Connected := False;
  inherited;
end;

Function TConnexionSQLite.Validate_Table : Boolean;
Var
  lTables : TStringList;
Begin
  Try
    lTables := TStringList.Create;
    Self.GetTableNames('', '', '', lTables,  [osMy, osSystem, osOther], [tkTable, tkView]);
    Result := lTables.IndexOf(Const_Table) > -1;
//    If Result Then
//    Begin
//      FQRY.SQL.Clear;
//      FQRY.SQL.Add(' DROP TABLE ' + Const_Table + ' ');
//      FQRY.ExecSQL;
//      Self.GetTableNames('', '', '', lTables,  [osMy, osSystem, osOther], [tkTable, tkView]);
//      Result :=  lTables.IndexOf(Const_Table) > -1;
//    End;
    If Not Result Then
    Begin
      FQRY.Active := False;
      FQRY.SQL.Clear;
      FQRY.SQL.Add(' CREATE TABLE ' + Const_Table + ' ');
      FQRY.SQL.Add(' ( ');
      FQRY.SQL.Add(' CODIGO NUMBER(22, 0) NOT NULL,  ');
      FQRY.SQL.Add(' URL VARCHAR2(600) NOT NULL, ');
      FQRY.SQL.Add(' DATAINICIO DATETIME NOT NULL, ');
      FQRY.SQL.Add(' DATAFIM DATETIME  ');
      FQRY.SQL.Add(' ) ');
      FQRY.ExecSQL;
      FQRY.Active := False;
      FQRY.SQL.Clear;
      Self.GetTableNames('', '', '', lTables,  [osMy, osSystem, osOther], [tkTable, tkView]);
       Result :=  lTables.IndexOf(Const_Table) > -1;
    End;
    lTables.Clear;
    FreeAndNil(lTables);
  Except
    On E: Exception Do
    Begin
      Last_Error := E.Message;
    End;
  End;
End;

Function TConnexionSQLite.MaxId(Var pResult : Integer) : Boolean;
Var
  lE : Integer;
Begin
  Result := True;
  pResult := 0;
  Try
    FQRY.Active := False;
    FQRY.SQL.Clear;
    FQRY.SQL.Add(' SELECT MAX(CODIGO) AS RESULT FROM ' + Const_Table + ' ');
    FQRY.Active := True;
    If Not FQRY.FieldByName('RESULT').IsNull Then
      Val(FQRY.FieldByName('RESULT').AsString, pResult, lE);
    Inc(pResult);
    FQRY.Active := False;
    FQRY.SQL.Clear;
  Except
    On E: Exception Do
    Begin
      Result := False;
      Last_Error := E.Message;
    End;
  End;
End;

Function TConnexionSQLite.Insert_LogDownload(Const pUrl : String; pDateInit, pDateEnd : TDateTime) : Boolean;
Var
  lMaxId : Integer;
Begin
  If MaxId(lMaxId) Then
  Begin
    Try
      FQRY.Active := False;
      FQRY.SQL.Clear;
      FQRY.SQL.Add(' INSERT INTO ' + Const_Table + ' ');
      FQRY.SQL.Add(' ( ');
      FQRY.SQL.Add(' CODIGO, ');
      FQRY.SQL.Add(' URL, ');
      FQRY.SQL.Add(' DATAINICIO, ');
      FQRY.SQL.Add(' DATAFIM ');
      FQRY.SQL.Add(' ) ');
      FQRY.SQL.Add(' VALUES ');
      FQRY.SQL.Add(' ( ');
      FQRY.SQL.Add(' :CODIGO, ');
      FQRY.SQL.Add(' :URL, ');
      FQRY.SQL.Add(' :DATAINICIO, ');
      FQRY.SQL.Add(' :DATAFIM ');
      FQRY.SQL.Add(' ) ');
      FQRY.Params.ParamByName('CODIGO'    ).AsInteger  := lMaxId;
      FQRY.Params.ParamByName('URL'       ).AsString   := pUrl;
      FQRY.Params.ParamByName('DATAINICIO').AsDateTime := pDateInit;
      FQRY.Params.ParamByName('DATAFIM'   ).AsDateTime := pDateEnd;
      FQRY.ExecSQL;
      FQRY.Active := False;
      FQRY.SQL.Clear;
    Except
      On E: Exception Do
      Begin
        Last_Error := E.Message;
      End;
    End;
  End;
End;

Initialization
  gConnexionSQLite := TConnexionSQLite.Create(Nil);

Finalization
  If Assigned(gConnexionSQLite) Then
    FreeAndNil(gConnexionSQLite);

end.
