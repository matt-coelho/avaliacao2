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
    Edit1: TEdit;
    Button1: TButton;
    Edit2: TEdit;
    FDConnection: TFDConnection;
    nomeProduto: TEdit;
    valorProduto: TEdit;
    Button2: TButton;
    SQLQuery: TFDQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

procedure TProva.Button1Click(Sender: TObject);
var produtos:Integer;
begin
  Edit1.Text := FloatToStr(contaDVD(StrToInt(Edit2.Text)));
end;

procedure TProva.Button2Click(Sender: TObject);
var np:string;
    vp:Double;
begin
  np := nomeProduto.Text;
  vp := StrToFloat(valorProduto.Text);

  insereProduto(vp, np);

  nomeProduto.Text := '';
  valorProduto.Text := '';
end;

procedure TProva.insereProdutoDesconto(idProduto:integer; quantidade:Integer; valor:double);
{
Escreva uma fun��o para inserir um registro na tabela ProdutoDesconto, usando
comandos SQL, que recebe como par�metro o c�digo do produto, a quantidade
inicial da faixa e o valor.
}
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

function TProva.insereProduto(valor:Double; nome:string):Integer;
{
Escreva uma fun��o para inserir um registro na tabela produto, usando comandos
SQL, que recebe como par�metro o nome do produto e o valor e retorna o c�digo
que deve ser gerado por esta fun��o.
}
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

function TProva.contaProduto(qtd:Integer; idProduto:Integer):double;
{
QUEST�O D) Escreva uma fun��o que utilize as fun��es criadas acima, para inserir
 os registros no banco de dados do problema do EXERC�CIO 1.
}
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

function TProva.contaDVD(qDVD:integer):double;
{
Uma loja vende DVDs por R$ 1,10 a unidade. Acima de 10 unidades, ser� vendido
cada DVD por R$ 1,00 a unidade adicional e acima de 20 unidades, ser� vendido
cada unidade adicional a R$ 0,90. Exemplo, vendendo 21 unidades dever� ser
cobrado 10x1.10+10x1.00+1x0.90. Escreva uma fun��o (utilizando Delphi / Pascal)
que receba a quantidade de DVDs a ser vendida e retorne o valor desta venda.
}
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

function TProva.valorVenda(idProduto:Integer; qtd:integer):double;
var total, valor:double;
{
QUEST�O E) Escreva uma fun��o que receba como par�metro o c�digo do produto e a
quantidade a ser vendida, e retorne o valor total da venda. Nesta quest�o dever�
 ser feito consultas �s tabelas criadas no exerc�cio anterior, de forma que
 implemente um algoritmo baseado na quest�o A) por�m com valores armazenados e
 n�o fixos.  Aten��o para o fato de que no exerc�cio A) s� temos duas faixas de
 desconto e, neste exerc�cio, as faixas de desconto est�o armazenadas na tabela.
}

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
