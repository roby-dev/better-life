using BetterLife.Application.Dashboard.Common;
using MediatR;

namespace BetterLife.Application.Dashboard.GetDashboardStats;

public sealed record GetDashboardStatsQuery(DateOnly? From, DateOnly? To) : IRequest<DashboardDto>;