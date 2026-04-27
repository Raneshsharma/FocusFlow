import 'dart:ui';
import '../../data/models/achievement.dart';

Color getTierColor(AchievementTier tier) {
  switch (tier) {
    case AchievementTier.bronze:
      return const Color(0xFFCD7F32);
    case AchievementTier.silver:
      return const Color(0xFFC0C0C0);
    case AchievementTier.gold:
      return const Color(0xFFFFD700);
    case AchievementTier.platinum:
      return const Color(0xFFE5E4E2);
  }
}

final achievementsCatalog = [
  // Bronze tier
  AchievementDefinition(
    id: 'first_flow',
    title: 'First Flow',
    description: 'Complete your first focus session',
    icon: '🎯',
    tier: AchievementTier.bronze,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 1,
  ),
  AchievementDefinition(
    id: 'task_starter',
    title: 'Task Starter',
    description: 'Complete your first task',
    icon: '✅',
    tier: AchievementTier.bronze,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalTasks >= 1,
  ),
  AchievementDefinition(
    id: 'deep_thinker',
    title: 'Deep Thinker',
    description: 'Complete a deep work session',
    icon: '🧠',
    tier: AchievementTier.bronze,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 1,
  ),

  // Silver tier
  AchievementDefinition(
    id: 'flow_starter',
    title: 'Flow Starter',
    description: 'Complete 5 focus sessions',
    icon: '⚡',
    tier: AchievementTier.silver,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 5,
  ),
  AchievementDefinition(
    id: 'productivity_machine',
    title: 'Productivity Machine',
    description: 'Complete 10 tasks',
    icon: '🚀',
    tier: AchievementTier.silver,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalTasks >= 10,
  ),
  AchievementDefinition(
    id: 'pomodoro_pro',
    title: 'Pomodoro Pro',
    description: 'Complete 4 pomodoro rounds in one session',
    icon: '🍅',
    tier: AchievementTier.silver,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 4,
  ),
  AchievementDefinition(
    id: 'getting_started',
    title: 'Getting Started',
    description: 'Achieve a 3-day streak',
    icon: '🔥',
    tier: AchievementTier.silver,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => currentStreak >= 3,
  ),

  // Gold tier
  AchievementDefinition(
    id: 'flow_regular',
    title: 'Flow Regular',
    description: 'Complete 20 focus sessions',
    icon: '💫',
    tier: AchievementTier.gold,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 20,
  ),
  AchievementDefinition(
    id: 'task_master',
    title: 'Task Master',
    description: 'Complete 25 tasks',
    icon: '👑',
    tier: AchievementTier.gold,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalTasks >= 25,
  ),
  AchievementDefinition(
    id: 'hot_streak',
    title: 'Hot Streak',
    description: 'Achieve a 7-day streak',
    icon: '🔥',
    tier: AchievementTier.gold,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => currentStreak >= 7,
  ),
  AchievementDefinition(
    id: 'deep_worker',
    title: 'Deep Worker',
    description: 'Complete 10 deep work sessions',
    icon: '🧠',
    tier: AchievementTier.gold,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 10,
  ),

  // Platinum tier
  AchievementDefinition(
    id: 'flow_expert',
    title: 'Flow Expert',
    description: 'Complete 50 focus sessions',
    icon: '🏆',
    tier: AchievementTier.platinum,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 50,
  ),
  AchievementDefinition(
    id: 'unstoppable',
    title: 'Unstoppable',
    description: 'Complete 50 tasks',
    icon: '💪',
    tier: AchievementTier.platinum,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalTasks >= 50,
  ),
  AchievementDefinition(
    id: 'legendary_streak',
    title: 'Legendary Streak',
    description: 'Achieve a 14-day streak',
    icon: '⚡',
    tier: AchievementTier.platinum,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => currentStreak >= 14,
  ),
  AchievementDefinition(
    id: 'super_focus',
    title: 'Super Focus',
    description: 'Complete 100 focus sessions',
    icon: '🌟',
    tier: AchievementTier.platinum,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalSessions >= 100,
  ),
  AchievementDefinition(
    id: 'task_legend',
    title: 'Task Legend',
    description: 'Complete 100 tasks',
    icon: '👑',
    tier: AchievementTier.platinum,
    isUnlocked: (totalSessions, totalTasks, currentStreak) => totalTasks >= 100,
  ),
];
