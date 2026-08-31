//
//  ScheduleSheetContext.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/3/26.
//

// MARK: - Schedule Sheet Context (추가/수정/복사)
enum ScheduleSheetContext: Identifiable {
    case add(selectedDates: [String])
    case edit(schedule: NewScheduleDTO)
    case copy(schedule: NewScheduleDTO)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let s): return "edit-\(s.id)"
        case .copy(let s): return "copy-\(s.id)"
        }
    }
}
