drop Table [dbo].[region]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[region](
	[region_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[region_name] [dbo].[shortstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[region_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[region] ADD  CONSTRAINT [region_status_default]  DEFAULT ('  ') FOR [region_code]
GO
ALTER TABLE [dbo].[region] ADD  CONSTRAINT [MSmerge_df_rowguid_8F77FBB4450545B19281AA866C492C39]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[region] ADD  CONSTRAINT [region_ident] PRIMARY KEY CLUSTERED 
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
