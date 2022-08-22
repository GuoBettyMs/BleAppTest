//
//  RecordBookWidgets.swift
//  RecordBookWidgets
//
//  Created by gbt on 2022/7/15.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    //在选择添加控件时，显示的数据
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    //根据时间轴获取网络真实数据
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        //1小时执行一次getTimeline，每次加载5条 SimplyEntry,因此每12分钟更新一次UI
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)

            entries.append(entry)
        }

        //policy: .atEnd, .atEnd执行完entries后立刻刷新；.never不刷新，可以调用WidgetCenter.shared.reloadAllTimelines()刷新所有widget，或者指定widget刷新；.after指定时间刷新
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

//第一个小组件 （每个app最多可以包含5种小组件）
struct WidgetOneEntryView: View {
    @Environment(\.widgetFamily) var family      //能从上下文环境中取到小组件的型号
    var entry: Provider.Entry           //组件数据
   
    //body 为要实现的组件布局
    var body: some View {
        
        VStack {
            HStack {
                Image("balloon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 120)
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(verbatim: "Variety is the spice of life")
//                        .font(.system(size: 18))
//                    Text(verbatim: "变化是生活的调味品")
//                        .font(.system(size: 15))
//                        .foregroundColor(.gray)
//                }
//                Spacer()            //等分剩余空间
            }
        }
    }
}
struct WidgetOne: Widget {
    let kind: String = "WidgetOne"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetOneEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}


//第二个小组件
struct WidgetTwoEntryView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            HStack {
                Image("balloon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                VStack(alignment: .leading, spacing: 10) {
                    Text(verbatim: "Variety is the spice of life")
                        .font(.system(size: 18))
                    Text(verbatim: "变化是生活的调味品")
                        .font(.system(size: 15))
                        .foregroundColor(.init(hexString: "#1F4D00"))
                }
                Spacer()            //等分剩余空间
            }
        }
    }
}
struct WidgetTwo: Widget{
    let kind: String = "WidgetTwo"
    
    var body: some WidgetConfiguration{
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()){
            entry in
            WidgetTwoEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}


@main
struct SwiftWidgetsBundle: WidgetBundle{
    @WidgetBundleBuilder
    var body: some Widget{
        WidgetOne()
        WidgetTwo()
    }
}

@available(iOS 13.0, *)
extension Color{
    //#ARGB
    init?(hexString: String) {
        var hex = hexString;
        guard hexString.starts(with: "#") else {
            return nil
        }
        hex.remove(at: hexString.startIndex)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        var a = 0xFF / 255.0
        if hex.count > 7 {
            a = Double(value >> 24) / 255.0
        }
        let r = Double((value & 0xFF0000) >> 16) / 255.0;
        let g = Double((value & 0xFF00) >> 8) / 255.0;
        let b = Double(value & 0xFF) / 255.0
        self.init(red: Double(r), green: Double(g), blue: Double(b))
        _ = self.opacity(Double(a))
    }
}


