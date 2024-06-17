using AccesiDatos.DataBase;
using Entidades.Estudiantes;
using System;
using System.Data;

namespace LogicaNegocio.Estudiantes
{
	public class ClsEstudianteLn
	{
		#region Variable privada
		private ClsDataBase ObjDataBase = null;
		#endregion

		#region Metodo index
		public void Index(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase = new ClsDataBase()
			{
				NombreTabla = "Estudiantes",
				NombreSP = "[SCH_GENERAL].[SP_Estudiantes_Index]",
				Scalar = false
			};
			Ejecutar(ref ObjEstudiante);
		}
		#endregion

		#region CRUD Estudiante
		public void Create(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase = new ClsDataBase()
			{
				NombreTabla = "Estudiantes",
				NombreSP = "[SCH_GENERAL].[SP_Estudiantes_Create]",
				Scalar = true
			};
			ObjDataBase.DtParametros.Rows.Add(@"@Nombre", "16", ObjEstudiante.Nombre);
			ObjDataBase.DtParametros.Rows.Add(@"@Apellido1", "16", ObjEstudiante.Apellido1);
			ObjDataBase.DtParametros.Rows.Add(@"@Apellido2", "16", ObjEstudiante.Apellido2);
			ObjDataBase.DtParametros.Rows.Add(@"@FechaNacimiento", "13", ObjEstudiante.FechaNacimiento);
			ObjDataBase.DtParametros.Rows.Add(@"@Estado", "1", ObjEstudiante.Estado);
			Ejecutar(ref ObjEstudiante);
		}
		public void Read(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase = new ClsDataBase()
			{
				NombreTabla = "Estudiantes",
				NombreSP = "[SCH_GENERAL].[SP_Estudiantes_Read]",
				Scalar = false
			};
			ObjDataBase.DtParametros.Rows.Add(@"@IdEstudiante", "2", ObjEstudiante.IdEstudiante);
			Ejecutar(ref ObjEstudiante);
		}
		public void Update(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase = new ClsDataBase()
			{
				NombreTabla = "Estudiantes",
				NombreSP = "[SCH_GENERAL].[SP_Estudiantes_Update]",
				Scalar = true
			};
			ObjDataBase.DtParametros.Rows.Add(@"@IdEstudiante", "2", ObjEstudiante.IdEstudiante);
			ObjDataBase.DtParametros.Rows.Add(@"@Nombre", "16", ObjEstudiante.Nombre);
			ObjDataBase.DtParametros.Rows.Add(@"@Apellido1", "16", ObjEstudiante.Apellido1);
			ObjDataBase.DtParametros.Rows.Add(@"@Apellido2", "16", ObjEstudiante.Apellido2);
			ObjDataBase.DtParametros.Rows.Add(@"@FechaNacimiento", "13", ObjEstudiante.FechaNacimiento);
			ObjDataBase.DtParametros.Rows.Add(@"@Estado", "1", ObjEstudiante.Estado);
			Ejecutar(ref ObjEstudiante);
		}
		public void Delete(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase = new ClsDataBase()
			{
				NombreTabla = "Estudiantes",
				NombreSP = "[SCH_GENERAL].[SP_Estudiantes_Delete]",
				Scalar = true
			};
			ObjDataBase.DtParametros.Rows.Add(@"@IdEstudiante", "2", ObjEstudiante.IdEstudiante);
			Ejecutar(ref ObjEstudiante);
		}
		#endregion

		#region Metodos privados
		private void Ejecutar(ref ClsEstudiante ObjEstudiante)
		{
			ObjDataBase.CRUD(ref ObjDataBase);
			if (ObjDataBase.MensajeErrorDB == null)
			{
				if (ObjDataBase.Scalar)
				{
					ObjEstudiante.ValorScalar = ObjDataBase.ValorScalar;
				}
				else
				{
					ObjEstudiante.DtResultado = ObjDataBase.DsResultado.Tables[0];
					if (ObjEstudiante.DtResultado.Rows.Count == 1)
					{
						foreach (DataRow item in ObjEstudiante.DtResultado.Rows)
						{
							ObjEstudiante.IdEstudiante = Convert.ToByte(item["IdEstudiante"].ToString());
							ObjEstudiante.Nombre = item["Nombre"].ToString();
							ObjEstudiante.Apellido1 = item["Apellido1"].ToString();
							ObjEstudiante.Apellido2 = item["Apellido2"].ToString();
							ObjEstudiante.FechaNacimiento = Convert.ToDateTime(item["FechaNacimiento"].ToString());
							ObjEstudiante.Estado = Convert.ToBoolean(item["Estado"].ToString());

						}
					}
				}
			}
			else
			{
				ObjEstudiante.MensajeError = ObjDataBase.MensajeErrorDB;
			}
		}
		#endregion
	}
}
