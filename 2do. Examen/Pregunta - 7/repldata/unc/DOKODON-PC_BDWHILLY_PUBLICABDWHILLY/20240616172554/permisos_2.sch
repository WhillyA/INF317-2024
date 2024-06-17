drop Table [dbo].[permisos]
go
SET ANSI_PADDING ON
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permisos](
	[id_permiso] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nombre_permiso] [varchar](50) NULL,
	[descripcion_permiso] [varchar](255) NULL,
	[crear] [bit] NULL,
	[eliminar] [bit] NULL,
	[modificar] [bit] NULL,
	[visualizar] [bit] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [DF__permisos__crear__1B0907CE]  DEFAULT ((0)) FOR [crear]
GO
ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [DF__permisos__elimin__1BFD2C07]  DEFAULT ((0)) FOR [eliminar]
GO
ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [DF__permisos__modifi__1CF15040]  DEFAULT ((0)) FOR [modificar]
GO
ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [DF__permisos__visual__1DE57479]  DEFAULT ((0)) FOR [visualizar]
GO
ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [MSmerge_df_rowguid_8ED2BD1C9BE9457C94A3D972FE09D50F]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[permisos] ADD  CONSTRAINT [PK__permisos__228F224F4D7F7694] PRIMARY KEY CLUSTERED 
(
	[id_permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
