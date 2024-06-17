drop Table [dbo].[provider]
go
SET ANSI_PADDING OFF
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[provider](
	[provider_no] [dbo].[numeric_id] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[provider_name] [dbo].[shortstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[provider_code] [dbo].[status_code] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL
)

GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_issue_dt_default]  DEFAULT (getdate()) FOR [issue_dt]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_expr_dt_default]  DEFAULT (dateadd(year,1,getdate())) FOR [expr_dt]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_status_default]  DEFAULT ('  ') FOR [provider_code]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [MSmerge_df_rowguid_AB5DF9FCA1B3400DA4764A61A07E44CD]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
SET ANSI_NULLS ON

go

SET QUOTED_IDENTIFIER ON

go

ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_ident] PRIMARY KEY CLUSTERED 
(
	[provider_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
