USE [master]
GO
/****** Object:  Database [BD_Estudiante]    Script Date: 09/06/2024 20:06:35 ******/
CREATE DATABASE [BD_Estudiante]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BD_Estudiante', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BD_Estudiante.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BD_Estudiante_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BD_Estudiante_log.ldf' , SIZE = 1040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BD_Estudiante] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BD_Estudiante].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BD_Estudiante] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BD_Estudiante] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BD_Estudiante] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BD_Estudiante] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BD_Estudiante] SET ARITHABORT OFF 
GO
ALTER DATABASE [BD_Estudiante] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BD_Estudiante] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [BD_Estudiante] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BD_Estudiante] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BD_Estudiante] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BD_Estudiante] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BD_Estudiante] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BD_Estudiante] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BD_Estudiante] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BD_Estudiante] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BD_Estudiante] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BD_Estudiante] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BD_Estudiante] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BD_Estudiante] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BD_Estudiante] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BD_Estudiante] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BD_Estudiante] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BD_Estudiante] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BD_Estudiante] SET RECOVERY FULL 
GO
ALTER DATABASE [BD_Estudiante] SET  MULTI_USER 
GO
ALTER DATABASE [BD_Estudiante] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BD_Estudiante] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BD_Estudiante] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BD_Estudiante] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [BD_Estudiante]
GO
/****** Object:  Schema [SCH_GENERAL]    Script Date: 09/06/2024 20:06:35 ******/
CREATE SCHEMA [SCH_GENERAL]
GO
/****** Object:  StoredProcedure [SCH_GENERAL].[SP_Estudiantes_Create]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SCH_GENERAL].[SP_Estudiantes_Create]
(
	@Nombre varchar(15)
	,@Apellido1 varchar(15)
	,@Apellido2 varchar(15)
	,@FechaNacimiento smalldatetime
	,@Estado bit
)
AS 
BEGIN
   INSERT INTO [SCH_GENERAL].[TBL_Estudiante]
           ([Nombre]
           ,[Apellido1]
           ,[Apellido2]
           ,[FechaNacimiento]
           ,[Estado])
     VALUES
           (@Nombre
           ,@Apellido1
           ,@Apellido2
           ,@FechaNacimiento
           ,@Estado)
SELECT SCOPE_IDENTITY()
END

GO
/****** Object:  StoredProcedure [SCH_GENERAL].[SP_Estudiantes_Delete]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SCH_GENERAL].[SP_Estudiantes_Delete]
(
@IdEstudiante tinyInt
)
AS
BEGIN
    DELETE 
    FROM [SCH_GENERAL].[TBL_Estudiante] WHERE IdEstudiante = @IdEstudiante;
select 1
END

GO
/****** Object:  StoredProcedure [SCH_GENERAL].[SP_Estudiantes_Index]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SCH_GENERAL].[SP_Estudiantes_Index]
AS
BEGIN
    SELECT [IdEstudiante],
           [Nombre],
           [Apellido1],
           [Apellido2],
           [FechaNacimiento],
           [Estado]
    FROM [SCH_GENERAL].[TBL_Estudiante];
END

GO
/****** Object:  StoredProcedure [SCH_GENERAL].[SP_Estudiantes_Read]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SCH_GENERAL].[SP_Estudiantes_Read]
(
@IdEstudiante tinyInt
)
AS
BEGIN
    SELECT [IdEstudiante],
           [Nombre],
           [Apellido1],
           [Apellido2],
           [FechaNacimiento],
           [Estado]
    FROM [SCH_GENERAL].[TBL_Estudiante] WHERE IdEstudiante = @IdEstudiante;
END

GO
/****** Object:  StoredProcedure [SCH_GENERAL].[SP_Estudiantes_Update]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SCH_GENERAL].[SP_Estudiantes_Update]
(
	@IdEstudiante tinyInt
	,@Nombre varchar(15)
	,@Apellido1 varchar(15)
	,@Apellido2 varchar(15)
	,@FechaNacimiento smalldatetime
	,@Estado bit
)
AS
BEGIN
	UPDATE [SCH_GENERAL].[TBL_Estudiante]
	   SET [Nombre] = @Nombre
		  ,[Apellido1] = @Apellido1
		  ,[Apellido2] = @Apellido2
		  ,[FechaNacimiento] = @FechaNacimiento
		  ,[Estado] = @Estado
	 WHERE IdEstudiante = @IdEstudiante
select 1
END

GO
/****** Object:  Table [SCH_GENERAL].[TBL_Estudiante]    Script Date: 09/06/2024 20:06:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [SCH_GENERAL].[TBL_Estudiante](
	[IdEstudiante] [tinyint] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](15) NOT NULL,
	[Apellido1] [varchar](15) NOT NULL,
	[Apellido2] [varchar](15) NULL,
	[FechaNacimiento] [smalldatetime] NOT NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IdEstudiante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [SCH_GENERAL].[TBL_Estudiante] ON 

INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (1, N'marcos', N'Ap_Paterno', NULL, CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (2, N'pedro', N'Ap_Paterno', N'Ap_Materno', CAST(0x7DB104BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (3, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (4, N'freddy', N'mamani', N'mamani', CAST(0x7E6B04BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (5, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (6, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (7, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (8, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0xB18304C7 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (9, N'Nombre', N'Ap_Paterno', N'Ap_Materno', CAST(0xB18304C7 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (10, N'carlos', N'sadsad', NULL, CAST(0xB18304C8 AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (11, N'carlos', N'sadsad', NULL, CAST(0xB18304C8 AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (12, N'carlos', N'sadsad', NULL, CAST(0xB18304C8 AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (13, N'carlos', N'sadsad', NULL, CAST(0xB18304C8 AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (14, N'asdasad', N'asd', N'asd', CAST(0xB18304CE AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (15, N'asdasad', N'asd', N'asd', CAST(0xB18304CE AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (16, N'alansa', N'asdsad', N'sadsad', CAST(0xB18304D1 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (17, N'alansa', N'asdsad', N'sadsad', CAST(0xB18304D1 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (18, N'sdadasd', N'asds', NULL, CAST(0xB18304DF AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (19, N'sdadasd', N'asds', NULL, CAST(0xB18304DF AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (20, N'adasdsadsad', N'dasdasd', N'asdsad', CAST(0xB18304EB AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (21, N'adasdsadsad', N'dasdasd', N'asdsad', CAST(0xB18304EB AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (22, N'wdfewef', N'wefefwefew', N'ewfewf', CAST(0xB18304F2 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (23, N'wdfewef', N'wefefwefew', N'ewfewf', CAST(0xB18304F2 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (24, N'wdfewef', N'wefefwefew', N'ewfewf', CAST(0xB18304F2 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (25, N'wdfewef', N'wefefwefew', N'ewfewf', CAST(0xB18304F2 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (26, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (27, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (28, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (29, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (30, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (31, N'cxzcC', N'czxc', N'czx', CAST(0xB18304F3 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (32, N'qwewq', N'qweqw', N'qweqw', CAST(0xB18304FD AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (33, N'qwewq', N'qweqw', N'qweqw', CAST(0xB18304FD AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (34, N'qwewq', N'qweqw', N'qweqw', CAST(0xB18304FD AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (35, N'qwewq', N'qweqw', N'qweqw', CAST(0xB18304FD AS SmallDateTime), 0)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (36, N'dsadf', N'sfdf', N'sdfdsf', CAST(0xB18304FE AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (37, N'dsadf', N'sfdf', N'sdfdsf', CAST(0xB18304FE AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (38, N'dsadf', N'sfdf', N'sdfdsf', CAST(0xB18304FE AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (40, N'asd', N'asds', N'asdsad', CAST(0xB1830504 AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (42, N'Whilly Edgar', N'Amoraga', N'Mamani', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (44, N'Whilly Edgar', N'Amoraga', N'Mamani', CAST(0x7DB504BD AS SmallDateTime), 1)
INSERT [SCH_GENERAL].[TBL_Estudiante] ([IdEstudiante], [Nombre], [Apellido1], [Apellido2], [FechaNacimiento], [Estado]) VALUES (46, N'<qwdasfhdsfds', N'dcdsr', N'dsfgb', CAST(0xB1830533 AS SmallDateTime), 1)
SET IDENTITY_INSERT [SCH_GENERAL].[TBL_Estudiante] OFF
USE [master]
GO
ALTER DATABASE [BD_Estudiante] SET  READ_WRITE 
GO
