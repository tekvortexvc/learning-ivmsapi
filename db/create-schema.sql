USE [ivms]
GO
/****** Object:  Table [dbo].[AttClass]    Script Date: 5/16/2024 2:40:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttClass](
	[id] [int] NULL,
	[AttClassName] [nvarchar](50) NULL,
	[CheckInTime] [time](7) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExclusionList]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExclusionList](
	[personName] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ivms]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ivms](
	[serialNo] [int] IDENTITY(1,1) NOT NULL,
	[employeeID] [nvarchar](50) NULL,
	[authDateTime] [datetime] NULL,
	[authDate] [date] NULL,
	[authTime] [time](7) NULL,
	[direction] [nvarchar](50) NULL,
	[deviceName] [nvarchar](50) NULL,
	[deviceSerialNo] [nvarchar](50) NULL,
	[personName] [nvarchar](50) NULL,
	[cardNo] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserClass]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserClass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personName] [nvarchar](50) NOT NULL,
	[attClassID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[USP_GetAverageAttDiff]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Niraj Bajracharya
-- Create date: 25 December 2023
-- Description:	Calculates difference between expected clock in/out time and actual time 
--				over past 30 days and returns average grouped by personName
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAverageAttDiff] 
	@TimeFrameInDays int = 30
AS
BEGIN
	set nocount on;
	set @TimeFrameInDays = @TimeFrameInDays + 1

	Begin /* Calculate authDiff */
		declare @authDiff table (personName nvarchar(max), authDate date, CheckIn time, CheckOut time, CheckInDiff int, CheckOutDiff int)
 
		insert into @authDiff
		select
			personName
			, authDate
			, min(authTime) 'CheckIn' --IN
			, case when min(authTime) = max(authTime) then null else max(authTime) end 'CheckOut' --OUT
			, DATEDIFF(minute, '09:00:00', min(authTime)) CheckInDiff
			, DATEDIFF(minute, '18:00:00', case when min(authTime) = max(authTime) then null else max(authTime) end) CheckOutDiff
		from ivms i
		where 
			authDate between convert(date,DATEADD(day,-@TimeFrameInDays,Getdate())) and convert(date,getdate())
			and datename(dw,authDate) not in ('Saturday','Sunday')			-- exclude weekends
			and authTime < '13:00:00'										-- exclude half day leave
			and personName not in (select personName from ExclusionList)	-- exclude support staff
		group by 
			personName, authDate
	End

	select personName, AVG(CheckInDiff) avgCheckInDiff, AVG(CheckOutDiff) avgCheckOutDiff
	from @authDiff 
	group by personName
	order by personName

END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetUserAverageAttDiff]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Niraj Bajracharya
-- Create date: 25 December 2023
-- Description:	Calculates difference between expected clock in/out time and actual time 
--				over past 30 days and returns average for personName
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetUserAverageAttDiff]
	@personName nvarchar(max),
	@TimeFrameInDays int = 30
	
AS
BEGIN
	set nocount on;
	set @TimeFrameInDays = @TimeFrameInDays + 1

	Begin /* Calculate authDiff */
		declare @authDiff table (personName nvarchar(max), authDate date, CheckIn time, CheckOut time, CheckInDiff int, CheckOutDiff int)
 
		insert into @authDiff
		select 
			personName
			, authDate
			, min(authTime) 'CheckIn' --IN
			, case when min(authTime) = max(authTime) then null else max(authTime) end 'CheckOut' --OUT
			, DATEDIFF(minute, '09:00:00', min(authTime)) CheckInDiff
			, DATEDIFF(minute, '18:00:00', case when min(authTime) = max(authTime) then null else max(authTime) end) CheckOutDiff
		from ivms i
		where 
			authDate between convert(date,DATEADD(day,-@TimeFrameInDays,Getdate())) and convert(date,getdate())
			and personName = @personName
			and datename(dw,authDate) not in ('Saturday','Sunday')			-- exclude weekends
			and authTime < '13:00:00'										-- exclude half day leave
		group by 
			personName, authDate
	End

	select personName, AVG(CheckInDiff) avgCheckInDiff, AVG(CheckOutDiff) avgCheckOutDiff
	from @authDiff 
	group by personName

END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetUserPunchIn]    Script Date: 5/16/2024 2:40:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GetUserPunchIn] 
	@personName nvarchar(100),
	@TimeFrameInDays int = 30
AS
BEGIN
	set nocount on;
	set @TimeFrameInDays = @TimeFrameInDays + 1

select
			personName
			, authDate
			, min(authTime) 'CheckIn' --IN
			--, case when min(authTime) = max(authTime) then null else max(authTime) end 'CheckOut' --OUT
			, DATEDIFF(minute, '09:00:00', min(authTime)) CheckInDiff
			--, DATEDIFF(minute, '18:00:00', case when min(authTime) = max(authTime) then null else max(authTime) end) CheckOutDiff
		from ivms i
		where 
			authDate between convert(date,DATEADD(day,-@TimeFrameInDays,Getdate())) and convert(date,getdate())
			and datename(dw,authDate) not in ('Saturday','Sunday')			-- exclude weekends
			and authTime < '13:00:00'										-- exclude half day leave
			and personName = @personName
		group by 
			personName, authDate

END
GO