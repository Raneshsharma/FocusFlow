# FocusFlow Library Redesign — ADHD-Friendly Design

**Date**: 2026-04-25
**Project**: FocusFlow Flutter App
**Purpose**: Redesign Library screen with ADHD-friendly features
**Approach**: Mixed — prioritize quick wins from "Prove it", "Catch the wave", and "Reduce friction"

---

## 1. Philosophy

ADHD people struggle with:
- **Rejection Sensitivity** — need proof they can do things
- **Energy management** — must work *with* energy, not fight it
- **Starting friction** — biggest barrier is the first step
- **Task blindness** — out of sight = out of mind
- **Working memory** — can't rely on remembering to do things

The Library should:
1. Show accomplishments to counter RSD ("you DID this")
2. Surface the right thing at the right energy level
3. Make starting as frictionless as possible
4. Keep favorites and templates visible/accessible
5. Support quick capture without breaking flow

---

## 2. Screen-by-Screen Design

---

### 2.1 SESSIONS — "Prove it to my brain"

**Purpose**: Show completed flow sessions as proof of capability

**Current**: List of sessions with duration/type

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **Flow Streak** | Show consecutive days with completed sessions |
| **"Prove It" Counter** | "You've had 47 productive sessions this month" |
| **Energy Pattern Chart** | When did you typically complete sessions? |
| **Quick Replay** | One-tap to restart a session template |
| **Mood Tagging** | Optional mood tag per session (optional, low friction) |
| **Session Highlights** | Star-worthy sessions appear in favorites too |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  📊 FLOW HISTORY                                 │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔥 Flow Streak: 5 days                  │   │
│  │    ████████░░░░  5/7 this week        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  "You've completed 23 sessions this month!"     │
│  That's 5 more than last month 🎉              │
│                                                 │
│  [Week] [Month] [All]                          │
│                                                 │
│  ─────────────────────────────────────────      │
│                                                 │
│  📅 Wed, Apr 23                                 │
│  "Deep Work" · 45 min · Great focus 🔥         │
│                                                 │
│  📅 Tue, Apr 22                                 │
│  "Quick Tasks" · 25 min                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: Add `moodTag` field to FlowSession

---

### 2.2 TEMPLATES — "Reduce friction to zero"

**Purpose**: One-tap start for pre-built task lists

**Current**: Grid of template cards

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **One-Tap Start** | Tap template → auto-loads tasks into zones |
| **"Use Last" Quick Button** | Instantly replay last template |
| **Time-of-Day Smart Sort** | Templates sorted by best time to use them |
| **Streak Templates** | Templates you've used 3+ times get badge |
| **Quick Clone** | Long-press to duplicate and edit |
| **Voice Template Creation** | "Add 5 quick tasks for tomorrow morning" |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  TEMPLATES                          [+ Create]   │
│                                                 │
│  [⭐ Use Last]  [🏃 Morning Routine]           │
│                                                 │
│  ┌───────────────┐ ┌───────────────┐           │
│  │ 🏃 Morning    │ │ 🌙 Evening    │           │
│  │ Quick Start   │ │ Wind Down     │           │
│  │ 3 tasks · 🔥  │ │ 4 tasks       │           │
│  │ Best: morning │ │ Best: evening │           │
│  └───────────────┘ └───────────────┘           │
│                                                 │
│  ┌───────────────┐ ┌───────────────┐           │
│  │ ⚡ Quick      │ │ 🧠 Deep      │           │
│  │ Energy Burst  │ │ Work Block    │           │
│  │ 5 tasks       │ │ 3 tasks · 🏆 │           │
│  └───────────────┘ └───────────────┘           │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: Add `bestTimeOfDay`, `streakCount`, `lastUsed` to Template model

---

### 2.3 FAVORITES — "Catch the wave"

**Purpose**: Quick access to tasks that work, auto-prioritized by energy

**Current**: List of starred tasks

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **Energy Auto-Tag** | Favorites tagged with energy level (high/medium/low) |
| **"Ready Fire" Section** | High-energy tasks sorted to top |
| **"Anytime Anchor"** | Low-energy tasks always accessible |
| **Time-of-Day Sort** | Favorites reorder based on current time |
| **Quick Energy Swap** | If energy changes mid-day, tap to shuffle |
| **Motivation Boost** | Show completed count on each favorite ("Done 8 times") |
| **Add to Today** | One-tap to add favorite to current day's tasks |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  ⭐ FAVORITES                                    │
│                                                 │
│  Ready to Fire 🔥                                │
│  ┌─────────────────────────────────────────┐   │
│  │ ⚡ Clean up inbox        Done 12 times │   │
│  │ ⚡ Reply pending emails   Done 8 times  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Anytime Anchors 🪝                              │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔋 Read one article       Done 5 times  │   │
│  │ 🔋 Organize files          Done 3 times  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Current Energy: High → Show fire tasks first   │
│  [Tap to shuffle based on energy →]            │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: Add `energyLevel`, `completionCount` to Task model

---

### 2.4 NOTES — "Voice dump + reflection"

**Purpose**: Capture thoughts without losing flow

**Current**: Session reflections only

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **Voice Capture** | Microphone button → speech to text note |
| **Quick Ideas Bucket** | Generic note capture, not tied to sessions |
| **Tag System** | #idea, #todo, #remember, #later |
| **AI Assistant Hook** | "Turn this note into a task?" |
| **Search + Filter** | Filter by tag, date, or content |
| **Session Linking** | Link notes to sessions for context |
| **Morning Review** | Suggested: "Review last night's notes" |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  📝 NOTES                            [+ Add]   │
│                                                 │
│  🔍 Search notes...                              │
│                                                 │
│  FILTER: [All] [#idea] [#todo] [#remember]     │
│                                                 │
│  📅 Apr 23 · Session Reflection                  │
│  "Deep work went well today. Try 45 min blocks  │
│   instead of 30." #reflection                    │
│                                                 │
│  📅 Apr 22 · Quick Idea                         │
│  "Should reorganize the bookshelf this weekend" │
│  #idea #later                                   │
│                                                 │
│  📅 Apr 20 · Morning Brain Dump                 │
│  "- Call mom\n- Email boss\n- Buy groceries"    │
│  #todo                                          │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🎤 Tap to capture a voice note...       │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: New `Note` model with `tags`, `sessionId?`, `isVoiceNote`, `content`

---

### 2.5 ARCHIVE — "Brag Document"

**Purpose**: Proof of completed work, celebrate wins

**Current**: List of completed tasks

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **"Brag It" Mode** | Toggle: see as celebration, not graveyard |
| **Weekly Win Report** | Auto-generate: "You completed 47 tasks this week!" |
| **Screenshots/Export** | Export archive as text for job interviews |
| **Celebration Unlocks** | Archive milestones unlock celebration animations |
| **"Restart" on Archive** | One-tap to move completed task back to active |
| **Category Stats** | Show breakdown: 20 Morning tasks, 15 Afternoon |
| **Year in Review** | Annual summary of accomplishments |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  🏆 ARCHIVE                                     │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🌟 THIS MONTH                            │   │
│  │    47 tasks completed                    │   │
│  │    12h 30m focus time                    │   │
│  │    Best day: Tuesday (9 tasks)           │   │
│  │    [Export as Text] [Share Win 🎉]      │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  FILTER: [All] [Morning] [Afternoon] [Evening] │
│                                                 │
│  Apr 23                                         │
│  ✅ Design homepage mockup                      │
│  ✅ Review pull requests                        │
│  ✅ Update documentation                        │
│                                                 │
│  Apr 22                                         │
│  ✅ Team standup                                │
│  ✅ Finish API integration                      │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: Add `categoryBreakdown`, `focusTimeTotal` aggregations

---

### 2.6 RESOURCES — "External brain"

**Purpose**: Save useful links, tools, references

**Current**: Manual URL list

**ADHD Enhancements**:

| Feature | Description |
|---------|-------------|
| **Smart Categorization** | Auto-tag: Article, Tool, Video, Course |
| **"Read Later" Queue** | Queue of links to consume during low energy |
| **One-Tap Open** | Open link directly from app |
| **Share Extension** | Receive URLs from other apps |
| **Resource Notes** | Add personal notes to each resource |
| **"Use in Session"** | Link resource to a task template |
| **Broken Link Checker** | Periodically check if saved links still work |

**UI Changes**:
```
┌─────────────────────────────────────────────────┐
│  🔗 RESOURCES                        [+ Add]     │
│                                                 │
│  🔍 Search resources...                         │
│                                                 │
│  📚 Read When Energy Is Low (5)                │
│  ┌─────────────────────────────────────────┐   │
│  │ 📄 Article: "How ADHD brains work"       │   │
│  │ 📄 Article: "Focus techniques"           │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  🛠️ Tools (3)                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ 🛠️ Notion — Project workspace          │   │
│  │ 🔧 Forest — Focus timer app             │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  🎥 Videos (2)                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ ▶️ "Productivity for ADHD" (45 min)     │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Data Changes**: Add `category` (article/tool/video/course), `notes`, `readLaterQueue` flag to Resource model

---

## 3. Data Model Changes

### New Models

```dart
// Note model
class Note {
  String id;
  String content;
  List<String> tags; // ['idea', 'todo', 'remember']
  String? sessionId; // linked session if applicable
  bool isVoiceNote;
  DateTime createdAt;
}

// Resource model (updated)
class Resource {
  String id;
  String title;
  String url;
  ResourceCategory category; // article, tool, video, course
  String? notes;
  bool readLaterQueue;
  DateTime createdAt;
}

enum ResourceCategory { article, tool, video, course }
```

### Updated Models

```dart
// FlowSession (updated)
class FlowSession {
  String? moodTag; // 'great', 'good', 'okay', 'struggled'
}

// Template (updated)
class Template {
  TimeOfDay? bestTimeOfDay;
  int streakCount;
  DateTime? lastUsed;
}

// Task (updated via existing model)
class Task {
  EnergyLevel energyLevel; // already exists
  int completionCount; // incremented on complete
}
```

---

## 4. Priority Implementation Order

### Tier 1 — Quick Wins (High impact, Low effort)
1. **Archive → Brag Document** — Add stats + export
2. **Sessions → Flow Streak** — Add streak counter + monthly stats
3. **Favorites → Energy Auto-Tag** — Sort by energy, show completion count
4. **Notes → Quick Add** — Add tag system + quick voice capture button

### Tier 2 — Medium Effort (Good impact)
5. **Templates → One-Tap Start** — Add streak badges + time-of-day sort
6. **Resources → Categorization** — Add category tags + "Read Later" queue

### Tier 3 — Nice to Have (Higher effort)
7. **Notes → AI Hook** — "Turn note into task" button
8. **All Screens → Full Polish** — Animations, celebration unlocks