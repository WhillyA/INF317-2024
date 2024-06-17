drop Table [dbo].[modulos]
go
SET ANSI_PADDING ON
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[modulos](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nombre] [varchar](255) NULL,
	[archivo] [varchar](255) NULL,
	[descripcion] [varchar](255) NULL,
	[id_permiso] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[modulos] ADD  CONSTRAINT [MSmerge_df_rowguid_AAB79E8239B740B7B7E28A0D983A76D0]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[modulos] ADD  CONSTRAINT [PK__modulos__3213E83F94FBF6F7] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
