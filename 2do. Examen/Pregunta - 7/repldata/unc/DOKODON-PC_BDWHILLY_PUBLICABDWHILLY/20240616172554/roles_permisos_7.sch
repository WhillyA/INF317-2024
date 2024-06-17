drop Table [dbo].[roles_permisos]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[roles_permisos](
	[id_rol] [int] NOT NULL,
	[id_permiso] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[roles_permisos] ADD  CONSTRAINT [MSmerge_df_rowguid_64826FC69E844A2FAFD140EAE74610B9]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[roles_permisos] ADD  CONSTRAINT [PK__roles_pe__889447C4CABA259D] PRIMARY KEY CLUSTERED 
(
	[id_rol] ASC,
	[id_permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
