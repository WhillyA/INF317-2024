using System;
using System.Collections.ObjectModel;
using System.Data;
using System.Data.SqlClient;

namespace AccesiDatos.DataBase
{
	public class ClsDataBase
	{
		#region Variables Privadas
		private SqlConnection _objSqlConnection;
		private SqlDataAdapter _ObjSqlDataAdapter;
		private SqlCommand _objSqlCommand;
		private DataSet _dsResultado;
		private DataTable _dtParametros;
		private string _nombreTabla, _nombreSP, _mensajeErrorDB, _valorScalar, _nombreDB;
		private bool _scalar;

		#endregion

		#region Variables Publicas
		public SqlConnection ObjSqlConnection { get => _objSqlConnection; set => _objSqlConnection = value; }
		public SqlDataAdapter ObjSqlDataAdapter { get => _ObjSqlDataAdapter; set => _ObjSqlDataAdapter = value; }
		public SqlCommand ObjSqlCommand { get => _objSqlCommand; set => _objSqlCommand = value; }
		public DataSet DsResultado { get => _dsResultado; set => _dsResultado = value; }
		public DataTable DtParametros { get => _dtParametros; set => _dtParametros = value; }
		public string NombreTabla { get => _nombreTabla; set => _nombreTabla = value; }
		public string NombreSP { get => _nombreSP; set => _nombreSP = value; }
		public string MensajeErrorDB { get => _mensajeErrorDB; set => _mensajeErrorDB = value; }
		public string ValorScalar { get => _valorScalar; set => _valorScalar = value; }
		public string NombreDB { get => _nombreDB; set => _nombreDB = value; }
		public bool Scalar { get => _scalar; set => _scalar = value; }
		#endregion

		#region Constructores
		public ClsDataBase()
		{
			DtParametros = new DataTable("SpParametros");
			DtParametros.Columns.Add("Nombre");
			DtParametros.Columns.Add("TipoDato");
			DtParametros.Columns.Add("Valor");

			NombreDB = "DB_Estudiante";
		}
		#endregion

		#region Metodos Privadas
		private void CrearConexionBaseDatos(ref ClsDataBase objDataBase)
		{
			switch (objDataBase.NombreDB)
			{
				case "DB_Estudiante":
					objDataBase.ObjSqlConnection = new SqlConnection(Properties.Settings.Default.CadenaConeccion_DB_Estudiante);
					break;
				default:
					break;
			}
		}
		private void ValidarConexionBaseDatos(ref ClsDataBase objDataBase)
		{
			if (objDataBase.ObjSqlConnection.State == ConnectionState.Closed)
			{
				objDataBase.ObjSqlConnection.Open();
			}
			else
			{
				objDataBase.ObjSqlConnection.Close();
				objDataBase.ObjSqlConnection.Dispose();
			}
		}
		private void AgregarParametros(ref ClsDataBase objDataBase)
		{
			if (objDataBase.DtParametros != null)
			{
				SqlDbType TipoDatoSql = new SqlDbType();

				foreach (DataRow item in objDataBase.DtParametros.Rows)
				{
					switch (item[1])
					{
						case "1":
							TipoDatoSql = SqlDbType.Bit;
							break;
						case "2":
							TipoDatoSql = SqlDbType.TinyInt;
							break;
						case "3":
							TipoDatoSql = SqlDbType.SmallInt;
							break;
						case "4":
							TipoDatoSql = SqlDbType.Int;
							break;
						case "5":
							TipoDatoSql = SqlDbType.BigInt;
							break;
						case "6":
							TipoDatoSql = SqlDbType.Decimal;
							break;
						case "7":
							TipoDatoSql = SqlDbType.SmallMoney;
							break;
						case "8":
							TipoDatoSql = SqlDbType.Money;
							break;
						case "9":
							TipoDatoSql = SqlDbType.Float;
							break;
						case "10":
							TipoDatoSql = SqlDbType.Real;
							break;
						case "11":
							TipoDatoSql = SqlDbType.Date;
							break;
						case "12":
							TipoDatoSql = SqlDbType.Time;
							break;
						case "13":
							TipoDatoSql = SqlDbType.SmallDateTime;
							break;
						case "14":
							TipoDatoSql = SqlDbType.Char;
							break;
						case "15":
							TipoDatoSql = SqlDbType.NChar;
							break;
						case "16":
							TipoDatoSql = SqlDbType.VarChar;
							break;
						case "17":
							TipoDatoSql = SqlDbType.NVarChar;
							break;
						case "18":
							TipoDatoSql = SqlDbType.DateTime;
							break;
						default:
							break;
					}
					if (objDataBase.Scalar)
					{
						if (item[2].ToString().Equals(string.Empty))
						{
							objDataBase.ObjSqlCommand.Parameters.Add(item[0].ToString(), TipoDatoSql).Value = DBNull.Value;
						}
						else
						{
							objDataBase.ObjSqlCommand.Parameters.Add(item[0].ToString(), TipoDatoSql).Value = item[2].ToString();
						}
					}
					else
					{
						if (item[2].ToString().Equals(string.Empty))
						{
							objDataBase.ObjSqlDataAdapter.SelectCommand.Parameters.Add(item[0].ToString(), TipoDatoSql).Value = DBNull.Value;
						}
						else
						{
							objDataBase.ObjSqlDataAdapter.SelectCommand.Parameters.Add(item[0].ToString(), TipoDatoSql).Value = item[2].ToString();
						}
					}
				}
			}
		}
		private void PrepararConexionesBaseDatos(ref ClsDataBase objDataBase)
		{
			CrearConexionBaseDatos(ref objDataBase);
			ValidarConexionBaseDatos(ref objDataBase);
		}
		private void EjecutarDataAdapter(ref ClsDataBase objDataBase)
		{
			try
			{
				PrepararConexionesBaseDatos(ref objDataBase);
				objDataBase.ObjSqlDataAdapter = new SqlDataAdapter(objDataBase.NombreSP, objDataBase.ObjSqlConnection);
				objDataBase.ObjSqlDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
				AgregarParametros(ref objDataBase);
				objDataBase.DsResultado = new DataSet();
				objDataBase.ObjSqlDataAdapter.Fill(objDataBase.DsResultado, objDataBase._nombreTabla);
			}
			catch (Exception ex) 
			{
				objDataBase.MensajeErrorDB = ex.Message.ToString();
			}
			finally
			{
				if (objDataBase.ObjSqlConnection.State == ConnectionState.Open)
				{
					ValidarConexionBaseDatos(ref objDataBase);
				}
			}
		}
		private void EjecutarCommand(ref ClsDataBase objDataBase)
		{
			try
			{
				PrepararConexionesBaseDatos(ref objDataBase);
				objDataBase.ObjSqlCommand = new SqlCommand(objDataBase.NombreSP, objDataBase.ObjSqlConnection)
				{
					CommandType = CommandType.StoredProcedure
				};
				AgregarParametros(ref objDataBase);

				if (objDataBase.Scalar)
				{
					objDataBase.ValorScalar = objDataBase.ObjSqlCommand.ExecuteScalar().ToString().Trim();
					objDataBase.ObjSqlCommand.ExecuteNonQuery();
				}
			}
			catch (Exception ex)
			{
				objDataBase.MensajeErrorDB = ex.Message.ToString();
			}
			finally
			{
				if (objDataBase.ObjSqlConnection.State == ConnectionState.Open)
				{
					ValidarConexionBaseDatos(ref objDataBase);
				}
			}
		}
		#endregion

		#region Metodos Publicos
		public void CRUD(ref ClsDataBase objDataBase)
		{
			if (objDataBase.Scalar)
			{
				EjecutarCommand(ref objDataBase);
			}
			else
			{
				EjecutarDataAdapter(ref objDataBase);
			}
		}
		#endregion
	}
}
