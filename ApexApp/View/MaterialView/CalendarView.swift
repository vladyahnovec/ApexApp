import SwiftUI

struct CalendarView: View {
    @ObservedObject var vm: ViewModel
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    var body: some View {
        ScrollView(.horizontal) {
            //MARK: - Ячейки календаря
            HStack(spacing: 10) {
                ForEach(getWeekDates(), id: \.self) { date in
                    VStack {
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundStyle(isToday(date) ? .white : .white)
                            .font(.custom("Montserrat-Light", size: 28))
                        
                        Text(daysOfWeek[dayOfWeekIndex(for: date)])
                            .foregroundStyle(isToday(date) ? .white : .gray)
                            .font(.custom("Montserrat-Light", size: 14))
                    }
                    .frame(width: 60, height: 80)
                    .background(isToday(date) ? .blue : .darkBlueColor)
                    .cornerRadius(12)
                    .onTapGesture {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "d.M"
                        vm.trainingDate = formatter.string(from: date)
                        print(vm.trainingDate)
                        vm.currentView = "UserTraining"
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(width: 350)
    }
    
    //MARK: - Функция получения дней недели
    private func getWeekDates() -> [Date] {
        let today = calendar.startOfDay(for: currentDate)
        let currentWeekday = calendar.component(.weekday, from: today)
        
        let daysToMonday = (currentWeekday == 1 ? -6 : 2 - currentWeekday)
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
    
    //MARK: - Проверка на текущий день
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    //MARK: - Получение правильного индекса дня недели
    private func dayOfWeekIndex(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday + 5) % 7
    }
}

#Preview {
    CalendarView(vm: ViewModel())
        .preferredColorScheme(.dark)
}
