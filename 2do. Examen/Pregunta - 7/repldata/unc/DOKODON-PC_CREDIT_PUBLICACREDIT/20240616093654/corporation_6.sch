drop Table [dbo].[corporation]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corporation](
	[corp_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[corp_name] [dbo].[normstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[corporation] ADD  CONSTRAINT [corporation_status_default]  DEFAULT ('  ') FOR [corp_code]
GO
ALTER TABLE [dbo].[corporation] ADD  CONSTRAINT [MSmerge_df_rowguid_4F856907D08349E4BD0E4D20E8CB4DAE]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[corporation] ADD  CONSTRAINT [corporation_ident] PRIMARY KEY CLUSTERED 
(
	[corp_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
