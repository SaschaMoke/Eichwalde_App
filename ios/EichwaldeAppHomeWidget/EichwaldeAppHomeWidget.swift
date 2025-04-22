//
//  EichwaldeAppHomeWidget.swift
//  EichwaldeAppHomeWidget
//
//  Created by Lenny Sieber on 22.04.25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private func getDataFromApp() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.eichwaldeApp")
        let textFromApp = userDefaults?.string(forKey: "data_from_eichwalde_app") ?? "Keine Daten verfügbar"
        return SimpleEntry(date: Date(), text: textFromApp)
    }
    
    //preview in widget gallery
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "0")
    }
    //Widget gallery selection preview
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: "0")
        completion(entry)
    }
    //actual widget
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getDataFromApp()

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
//data structure
struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}
//design
struct EichwaldeAppHomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Data:")
            Text(entry.text)
        }
    }
}
//main widget config
struct EichwaldeAppHomeWidget: Widget {
    let kind: String = "EichwaldeAppHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                EichwaldeAppHomeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                EichwaldeAppHomeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
//preview werte in selection
#Preview(as: .systemSmall) {
    EichwaldeAppHomeWidget()
} timeline: {
    SimpleEntry(date: .now, text: "0")
    SimpleEntry(date: .now, text: "0")
}
