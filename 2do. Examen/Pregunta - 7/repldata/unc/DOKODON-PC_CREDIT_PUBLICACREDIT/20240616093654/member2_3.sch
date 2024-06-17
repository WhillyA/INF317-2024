drop Table [dbo].[member2]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[member2](
	[member_no] [dbo].[numeric_id] NOT NULL,
	[lastname] [dbo].[shortstring] NOT NULL,
	[firstname] [dbo].[shortstring] NOT NULL,
	[middleinitial] [dbo].[letter] NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NULL,
	[photograph] [image] NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_no] [dbo].[numeric_id] NULL,
	[prev_balance] [money] NULL,
	[curr_balance] [money] NULL,
	[member_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[member2] ADD  CONSTRAINT [MSmerge_df_rowguid_84B2D79F6E6045728ECA8F27C02FA465]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

CREATE CLUSTERED INDEX [member2Cl] ON [dbo].[member2]
(
	[lastname] ASC,
	[firstname] ASC,
	[middleinitial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
