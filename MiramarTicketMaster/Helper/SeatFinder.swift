//
//  SeatFinder.swift
//  MiramarTicketMaster
//
//  Created by Wayne on 2019/4/11.
//  Copyright © 2019 Wayne. All rights reserved.
//

import Foundation

class SeatFinder {
    
    let targetSeats: [TargetSeatRange]
    let targetTicketQuantity: Int
    
    init(targetSeats: [TargetSeatRange], targetTicketQuantity: Int) {
        self.targetSeats = targetSeats
        self.targetTicketQuantity = targetTicketQuantity
    }
    
    func seats(from seatPlan: SeatPlan) -> [SeatPlan.SeatLayoutData.Area.Row.Seat] {
        log.debug("Request for session seat data success!")
        log.debug("Get areas count \(seatPlan.areas.count)")
        
        guard let area = seatPlan.areas.first else {
            log.debug("No area could be found...")
            return []
        }
            
        log.debug("Get rows count \(area.rows.count)")
        
        var selectedSeats = [SeatPlan.SeatLayoutData.Area.Row.Seat]()
        var selectedSeatsScores: Int = 0
        let maxSeatPriorityScore: Int = Int(round(Double(area.rows.reduce(0, { max($0, $1.seats.count) })) / 2.0))
            
        for targetSeat in self.targetSeats {
            guard let row = area.rows.first(where: { $0.physicalName == .some(targetSeat.row) }) else {
                log.debug("Target row \(targetSeat.row) couldn't be found...")
                continue
            }
            
            var currentPickedSeats = [SeatPlan.SeatLayoutData.Area.Row.Seat]()
            let seats = row.seats.filter{ targetSeat.range.contains($0.id.intValue) }
            seats.forEach { (seat) in
                let seatId = seat.id.intValue
                seat.score = (seat.seatStatus == .empty) ?
                    maxSeatPriorityScore - (seatId - maxSeatPriorityScore).abs :
                    -(maxSeatPriorityScore)
                
                currentPickedSeats.append(seat)
                if currentPickedSeats.count > self.targetTicketQuantity {
                    currentPickedSeats.removeFirst()
                }
                
                if currentPickedSeats.count == self.targetTicketQuantity {
                    /// Make sure all seats are available.
                    guard currentPickedSeats.filter({ $0.seatStatus != .empty }).isEmpty else { return }
                    
                    /// Compare two seats array and picked the one with higher scores.
                    let pickedSeatsScore = currentPickedSeats.reduce(0, { $0 + $1.score })
                    if pickedSeatsScore >= selectedSeatsScores {
                        selectedSeats = currentPickedSeats
                        selectedSeatsScores = pickedSeatsScore
                    }
                }
            }
            
            if !selectedSeats.isEmpty {
                break
            }
        }
        
        guard selectedSeats.count == targetTicketQuantity else {
            log.debug("Available seats are not enough...")
            return []
        }
        
        return selectedSeats
    }
}
