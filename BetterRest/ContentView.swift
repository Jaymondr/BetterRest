//
//  ContentView.swift
//  BetterRest
//
//  Created by Jaymond Richardson on 6/17/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") {
                    HStack {
                        Text(wakeUp.formatted(date: .omitted, time: .shortened))
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .onChange(of: wakeUp, perform: { _ in
                                calculateBedtime()
                            })
                            .labelsHidden()
                    }
                }
                .padding(.leading, -15)
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25) { _ in
                        calculateBedtime()
                    }
                        .padding(.leading, 15)
                }
                .padding(.leading, -15)
                                
                Section("Daily coffee intake")  {
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { Text("\($0)") }
                }
                        .padding(.leading, 15)
                        .onChange(of: coffeeAmount) { _ in
                            calculateBedtime()
                        }
                }
                .padding(.leading, -15)
                
                Section("Recommended bed time") {
                    HStack {
                        Text("\(alertTitle): ")
                            .padding(.leading, 15)
                            .font(.title3)
                        Spacer()
                        Text(alertMessage)
                    }
                }
                .font(.title3)
                .padding(.leading, -15)
            }
            .navigationTitle("BetterRest")
        }
        .onAppear(perform: calculateBedtime)
    }
    
    func calculateBedtime() {
        do {
          let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let componenets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (componenets.hour ?? 0) * 60 * 60
            let minute = (componenets.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error "
            alertMessage = "Sorry, here was an error calculating your bedtime"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
