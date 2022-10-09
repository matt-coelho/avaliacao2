unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TProva = class(TForm)
    edtTotal: TEdit;
    btnDVDs: TButton;
    edtNdvds: TEdit;
    FDConnection: TFDConnection;
    nomeProduto: TEdit;
    valorProduto: TEdit;
    btnCproduto: TButton;
    SQLQuery: TFDQuery;
    procedure btnDVDsClick(Sender: TObject);
    procedure btnCprodutoClick(Sender: TObject);
  private
    function contaDVD(qDVD:integer):Double;
    function insereProduto(valor:Double; nome:string):Integer;
    function valorVenda(idProduto:Integer; qtd:integer):double;
    function contaProduto(qtd:Integer; idProduto:Integer):double;
    procedure insereProdutoDesconto(idProduto:integer; quantidade:Integer; valor:double);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Prova: TProva;

implementation

{$R *.dfm}

procedure TProva.btnDVDsClick(Sender: TObject);
var produtos:Integer;
begin
  edtTotal.Text := FloatToStr(contaDVD(StrToInt(edtNdvds.Text)));
end;

procedure TProva.btnCprodutoClick(Sender: TObject);
var np:string;
    vp:Double;
begin
  np := nomeProduto.Text;
  vp := StrToFloat(valorProduto.Text);

  insereProduto(vp, np);

  nomeProduto.Text := '';
  valorProduto.Text := '';
end;

procedure TProva.insereProdutoDesconto(idProduto:integer; quantidade:Integer; valor:double); //1
begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('SET IDENTITY_INSERT produtodesconto ON');
  SQLQuery.SQL.Add('insert into produtodesconto (quantidade, idproduto, valor) values(:quantidade, :idproduto, :valor)');
  SQLQuery.ParamByName('quantidade').AsInteger := quantidade;
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.SQL.Add('SET IDENTITY_INSERT produtodesconto ON');
  SQLQuery.Prepare;
  SQLQuery.ExecSQL;
  SQLQuery.Close;
end;

function TProva.insereProduto(valor:Double; nome:string):Integer; //2
var id:Integer;
begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('insert into produto (nome, valor)values(:nome, :valor)');
  SQLQuery.ParamByName('nome').AsString := nome;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.Prepare;
  SQLQuery.ExecSQL;

  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select idProduto from produto where nome=:nome and valor=:valor');
  SQLQuery.ParamByName('nome').AsString := nome;
  SQLQuery.ParamByName('valor').AsFloat := valor;
  SQLQuery.Prepare;
  SQLQuery.Open();
  id := SQLQuery.FieldByName('idProduto').AsInteger;

  SQLQuery.Close;
  insereProduto := id;
end;

function TProva.contaProduto(qtd:Integer; idProduto:Integer):double;//3
var total, valor:Double;
    qtdItens:Integer;
  procedure incrementaTotal(conta:double);
  begin
    total := total + conta;
  end;
begin
  qtdItens := qtd;
  SQLQuery.close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select valor from produto where idproduto=:idproduto');
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.Prepare;
  SQLQuery.Open();
  valor := SQLQuery.FieldByName('valor').AsFloat;
  SQLQuery.Close;
  total := 0; //desconto
  while(qtd >= 10) do
  begin
    incrementaTotal(10 * valor);
    valor := valor - 0.10;
    qtd := qtd - 10;
  end;
  if qtd > 0 then
    incrementaTotal(qtd * valor);
  insereProdutoDesconto(idProduto, qtdItens, total);
  contaProduto := total;
end;

function TProva.contaDVD(qDVD:integer):double; //4
var total, valorDVD:Double;
    totalDVDs:Integer;
  procedure incrementaTotal(valor:double);
  begin
    total := total + valor;
  end;
begin
  totalDVDs := qDVD;
  valorDVD := 1.10;
  total := 0;
  while(qDVD >= 10) do
  begin
    incrementaTotal(10 * valorDVD);
    valorDVD := valorDVD - 0.10;
    qDVD := qDVD - 10;
  end;
  if qDVD > 0 then
    incrementaTotal(qDVD * valorDVD);
  insereProdutoDesconto(2, totalDVDs, total);
  contaDVD := total;
end;

function TProva.valorVenda(idProduto:Integer; qtd:integer):double; //5
var total, valor:double;
begin
  SQLQuery.Close;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('select * from produtodesconto where idProduto=:idproduto');
  SQLQuery.SQL.Add(' and quantidade=:qtd');
  SQLQuery.ParamByName('idproduto').AsInteger := idProduto;
  SQLQuery.ParamByName('qtd').AsInteger := qtd;
  SQLQuery.Prepare;
  SQLQuery.Open();
  if(SQLQuery.RecordCount = 1) then
  begin
    total := SQLQuery.FieldByName('valor').AsFloat;
    SQLQuery.Close;
  end else
  begin
    total := contaProduto(qtd,idProduto)
  end;
  valorVenda := total;
end;

end.
