//: Playground - noun: a place where people can play
//@Author Jeremiah Milbauer
//Licensing: Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International

import UIKit

extension NSDate {
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}

protocol Encodable {
    func encodeMe() -> NSMutableDictionary
    //mutating func decodeMe(dictionary: NSMutableDictionary)
}

protocol MEDEvent: Encodable {
    
    //fields
    var date: NSDate { get set }
    var context: String { get set }
    var symptoms: [Symptom] { get set }
    var fife: String { get set }
    var diagnostics: [Diagnostic] { get set }
    
}

enum ScheduleInterval { //done
    case Hour, Day, Week, Month, Year, AsNeeded
    func toString() -> String {
        switch self {
        case .Hour: return "Hourly"
        case .Day: return "Daily"
        case .Week: return "Weekly"
        case .Month: return "Monthly"
        case .Year: return "Yearly"
        case .AsNeeded: return "As Needed"
        }
    }
}

struct Symptom: Encodable {
    var description: String
    var severity: Int
    
    func encodeMe() -> NSMutableDictionary {
        let res: NSMutableDictionary = [
            "description" : description,
            "severity" : severity
        ]
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.description = dict["description"] as! String
        self.severity = dict["severity"] as! Int
    }
}

struct Diagnosis: Encodable {
    var date_made: NSDate
    var icd: String
    var diagnosis_name: String
    var date_resolved: NSDate?
    
    func encodeMe() -> NSMutableDictionary {
        if date_resolved == nil {
            
            let res: NSMutableDictionary = [
                "date_made" : date_made,
                "icd" : icd,
                "diagnosis_name" : diagnosis_name
            ]
            
            return res
        } else {
            
            let res: NSMutableDictionary = [
                "date_made" : date_made,
                "icd" : icd,
                "diagnosis_name" : diagnosis_name,
                "date_resolved" : date_resolved!
            ]
            
            return res
            
        }
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.date_made = dict["date_made"] as! NSDate
        self.icd = dict["icd"] as! String
        self.diagnosis_name = dict["diagnosis_name"] as! String
        self.date_resolved = dict["date_resolved"] as? NSDate
    }
}

struct ImmunizationInfo: Encodable {
    var type: String
    var date: NSDate
    
    func encodeMe() -> NSMutableDictionary {
        
        let res: NSMutableDictionary = [
            "type" : type,
            "date" : date
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.type = dict["type"] as! String
        self.date = dict["date"] as! NSDate
    }
}

struct Status: Encodable {
    var allergies: [String]
    var immunizations: [ImmunizationInfo]
    
    func encodeMe() -> NSMutableDictionary {
        
        var encodedImmunizations: [NSMutableDictionary] = []
        for imm in immunizations {
            encodedImmunizations.append(imm.encodeMe())
        }
        
        let res: NSMutableDictionary = [
            "allergies" : allergies,
            "immunizations" : encodedImmunizations
        
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.allergies = dict["allergies"] as! [String]
        
        immunizations = []
        for imm in dict["immunizations"] as! [NSMutableDictionary] {
            var immInfo: ImmunizationInfo = ImmunizationInfo(type: "null", date: NSDate(dateString: "1975-01-01"))
            immInfo.decodeMe(imm)
            immunizations.append(immInfo)
        }
    }
}


struct Patient: Encodable {
    var name: String
    var dob: NSDate
    var sex: Bool
    
    func sexToString() -> String {
        if sex {
            return "Male"
        } else {
            return "Female"
        }
    }

    var gender: String
    
    var problems: [Diagnosis]
    var personalHistory: [MEDEvent]
    var statusdata: Status
    
    var ongoingMedications: [Medication]
    
    func encodeMe() -> NSMutableDictionary {
        
        var problemList: [NSMutableDictionary] = []
        for prob in problems {
            problemList.append(prob.encodeMe())
        }
        
        var eventList: [NSMutableDictionary] = []
        for eve in personalHistory {
            eventList.append(eve.encodeMe())
        }
        
        var medList: [NSMutableDictionary] = []
        for ong in ongoingMedications {
            medList.append(ong.encodeMe())
        }
        
        
        let res: NSMutableDictionary = [
            "name" : name,
            "dob" : dob,
            "sex" : sex,
            "gender" : gender,
            "problems" : problemList,
            "personalHistory" : eventList,
            "statusdata" : statusdata.encodeMe(),
            "ongoingMedications" : medList
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.name = dict["name"] as! String
        self.dob = dict["dob"] as! NSDate
        self.sex = dict["sex"] as! Bool
        self.gender = dict["gender"] as! String
        
        self.problems = []
        for prob in dict["problems"] as! [NSMutableDictionary] {
            var problem: Diagnosis = Diagnosis(date_made: NSDate(dateString: "1975-01-01"), icd: "", diagnosis_name: "", date_resolved: nil)
            problem.decodeMe(prob)
            self.problems.append(problem)
        }
        
        self.personalHistory = []
        for eve in dict["personalHistory"] as! [NSMutableDictionary] {
            let isNote = eve["further_action"] != nil
            if isNote {
                var eveInfo: Visit = Visit(date: NSDate(dateString: "2000-01-01"), context: "", symptoms: [], fife: "", diagnostics: [], physician: Physician(name: "", npi: 0), location: "", date_out: NSDate(dateString: "2000-01-01"), description: "", medications: [], procedures: [])
                eveInfo.decodeMe(eve)
                self.personalHistory.append(eveInfo)
            } else {
                var eveInfo: Note = Note(date: NSDate(dateString: "2000-01-01"), context: "", symptoms: [], fife: "", diagnostics: [], further_action: "")
                eveInfo.decodeMe(eve)
                self.personalHistory.append(eveInfo)
            }
        }
        
        var statusInfo = Status(allergies: [], immunizations: [])
        statusInfo.decodeMe(dict["statusdata"] as! NSMutableDictionary)
        self.statusdata = statusInfo
        
        
    }
    
}

struct Physician: Encodable { //done
    var name: String
    var npi: Int
    
    
    func encodeMe() -> NSMutableDictionary {
        
        let res: NSMutableDictionary = [
            "name" : name,
            "npi" : npi
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.name = dict["name"] as! String
        self.npi = dict["npi"] as! Int
    }
}
    
    
//    
//    init(name: String, id: Int) {
//        self.name = name
//        self.npi = id
//    }
//    
//    override init() {
//        super.init()
//    }
//    
//    //MARK: NSCoding
//    
//    required convenience init(coder decoder: NSCoder) {
//        self.init()
//        self.name = decoder.decodeObjectForKey("name") as? String
//        self.npi = decoder.decodeIntegerForKey("npi")
//    }
//    
//    func encodeWithCoder(coder: NSCoder) {
//        coder.encodeObject(self.name, forKey: "name")
//        coder.encodeInteger((self.npi), forKey: "npi")
//    }


struct Diagnostic: Encodable { //done
    var when: NSDate
    var self_reported: Bool
    var labname: String
    var value: Double
    var description: String
    
    func encodeMe() -> NSMutableDictionary {
    
        let res: NSMutableDictionary = [
            "when" : when,
            "self_reported" : self_reported,
            "labname" : labname,
            "value" : value,
            "description" : description
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.when = dict["when"] as! NSDate
        self.self_reported = dict["self_reported"] as! Bool
        self.labname = dict["labname"] as! String
        self.value = dict["value"] as! Double
        self.description = dict["description"] as! String
    }
    
}

struct Procedure: Encodable { //done
    var when: NSDate
    var physician: Physician
    var reason: String
    var complications: String
    var notes: String
    
    func encodeMe() -> NSMutableDictionary {
        
        let res: NSMutableDictionary = [
            "when" : when,
            "physician" : physician.encodeMe(),
            "reason" : reason,
            "complications" : complications,
            "notes" : notes
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.when = dict["when"] as! NSDate
        
        var physicianInfo: Physician = Physician(name: "", npi: 0)
        physicianInfo.decodeMe(dict["physician"] as! NSMutableDictionary)
        self.physician = physicianInfo
        
        self.reason = dict["reason"] as! String
        self.complications = dict["complications"] as! String
        self.notes = dict["notes"] as! String
    }
}

struct Medication: Encodable { //done
    var name: String
    var reason: String
    var warnings: [String]
    var dose: String
    var start: NSDate
    var end: NSDate?
    
    func encodeMe() -> NSMutableDictionary {
        if end != nil {
            
            let res: NSMutableDictionary = [
                "name" : name,
                "reason" : reason,
                "warnings" : warnings,
                "dose" : dose,
                "start" : start,
                "end" : end!
            ]
            
            return res
    
        } else {
    
            let res: NSMutableDictionary = [
                "name" : name,
                "reason" : reason,
                "warnings" : warnings,
                "dose" : dose,
                "start" : start,
            ]
            
            return res
            
        }
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.name = dict["name"] as! String
        self.reason = dict["reason"] as! String
        self.warnings = dict["warnings"] as! [String]
        self.dose = dict["dose"] as! String
        self.start = dict["start"] as! NSDate
        self.end = dict["end"] as? NSDate
    }
}


struct Note: MEDEvent {
    
    //inherited fields
    var date: NSDate
    var context: String
    var symptoms: [Symptom]
    var fife: String
    var diagnostics: [Diagnostic]

    //fields
    var further_action: String
    
    func encodeMe() -> NSMutableDictionary {
        
        var symptomList: [NSMutableDictionary] = []
        for sym in symptoms {
            symptomList.append(sym.encodeMe())
        }
        
        var diagnosticList: [NSMutableDictionary] = []
        for dia in diagnostics {
            diagnosticList.append(dia.encodeMe())
        }
        
        let res: NSMutableDictionary = [
            "date" : date,
            "context" : context,
            "symptoms" : symptomList,
            "fife" : fife,
            "diagnostics" : diagnosticList,
            "further_action" : further_action
        ]
        
        return res
    }
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.date = dict["date"] as! NSDate
        self.context = dict["context"] as! String
        
        self.symptoms = []
        for sym in dict["symptoms"] as! [NSMutableDictionary] {
            var symptomHelper: Symptom = Symptom(description: "", severity: 0)
            symptomHelper.decodeMe(sym)
            self.symptoms.append(symptomHelper)
        }
        
        self.fife = dict["fife"] as! String
        
        self.diagnostics = []
        for diag in dict["diagnostics"] as! [NSMutableDictionary] {
            var diagnosticHelper: Diagnostic = Diagnostic(when: NSDate(dateString: "2000-01-01"), self_reported: false, labname: "", value: 0.0, description: "")
            diagnosticHelper.decodeMe(diag)
            self.diagnostics.append(diagnosticHelper)
        }
    }
}

struct Visit: MEDEvent {
    
    //inherited fields
    var date: NSDate
    var context: String
    var symptoms: [Symptom]
    var fife: String
    var diagnostics: [Diagnostic]
    
    //fields
    var physician: Physician
    var location: String
    var date_out: NSDate
    var description: String //description of care
    var medications: [Medication]
    var procedures: [Procedure]
    

    func encodeMe() -> NSMutableDictionary {
        
        var symptomList: [NSMutableDictionary] = []
        for sym in symptoms {
            symptomList.append(sym.encodeMe())
        }
        
        var diagnosticList: [NSMutableDictionary] = []
        for dia in diagnostics {
            diagnosticList.append(dia.encodeMe())
        }
        
        var medicationList: [NSMutableDictionary] = []
        for med in medications {
            medicationList.append(med.encodeMe())
        }
        
        var procedureList: [NSMutableDictionary] = []
        for pro in procedures {
            procedureList.append(pro.encodeMe())
        }
        
        let res: NSMutableDictionary = [
            "date" : date,
            "context" : context,
            "symptoms" : symptomList,
            "fife" : fife,
            "diagnostics" : diagnosticList,
            "physician" : physician.encodeMe(),
            "location" : location,
            "date_out" : date_out,
            "description" : description,
            "medications" : medicationList,
            "procedures" : procedureList
        ]
        
        return res
    }
    
//    var date: NSDate
//    var context: String
//    var symptoms: [Symptom]
//    var fife: String
//    var diagnostics: [Diagnostic]
//    
//    //fields
//    var physician: Physician
//    var location: String
//    var date_out: NSDate
//    var description: String //description of care
//    var medications: [Medication]
//    var procedures: [Procedure]
    
    mutating func decodeMe(dict: NSMutableDictionary) {
        self.date = dict["date"] as! NSDate
        self.context = dict["context"] as! String
        
        self.symptoms = []
        for sym in dict["symptoms"] as! [NSMutableDictionary] {
            var symptomHelper: Symptom = Symptom(description: "", severity: 0)
            symptomHelper.decodeMe(sym)
            self.symptoms.append(symptomHelper)
        }
        
        self.fife = dict["fife"] as! String
        
        self.diagnostics = []
        for diag in dict["diagnostics"] as! [NSMutableDictionary] {
            var diagnosticHelper: Diagnostic = Diagnostic(when: NSDate(dateString: "2000-01-01"), self_reported: false, labname: "", value: 0.0, description: "")
            diagnosticHelper.decodeMe(diag)
            self.diagnostics.append(diagnosticHelper)
        }
        
        var physicianHelper: Physician = Physician(name: "", npi: 0)
        physicianHelper.decodeMe(dict["physician"] as! NSMutableDictionary)
        self.physician = physicianHelper
        
        self.location = dict["location"] as! String
        self.date_out = dict["date_out"] as! NSDate
        self.description = dict["description"] as! String
        
        self.medications = []
        for med in dict["medications"] as! [NSMutableDictionary] {
            var medicationHelper: Medication = Medication(name: "", reason: "", warnings: [], dose: "", start: NSDate(dateString: "2000-01-01"), end: nil)
            medicationHelper.decodeMe(med)
            self.medications.append(medicationHelper)
        }
        
        self.procedures = []
        for proc in dict["procedures"] as! [NSMutableDictionary] {
            var procedureHelper: Procedure = Procedure(when: NSDate(dateString: "2000-01-01"), physician: Physician(name: "", npi: 0), reason: "", complications: "", notes: "")
            procedureHelper.decodeMe(proc)
            self.procedures.append(procedureHelper)
        }
    }
}


struct PList {
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name: String
    
    var sourcePath:String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    
    var destPath: String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        self.name = name
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }
        
        if !fileManager.fileExistsAtPath(destination) {
            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. Error: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func addValuesToPlistFile(dictionary:NSMutableDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            if !dictionary.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}

let arnie_tetanus = ImmunizationInfo(type: "Tetanus", date: NSDate(dateString: "2014-03-17"))
let arnie_status = Status(allergies: ["Peanuts", "Penicillin"], immunizations: [arnie_tetanus])
let arnie_pneumo = Diagnosis(date_made: NSDate(dateString: "2016-07-28"), icd: "J9311", diagnosis_name: "Primary Spontaneous Pneumothorax", date_resolved: nil)

let arnie_symptom = Symptom(description: "Sharp chest pain", severity: 4)
let arnie_note = Note(date: NSDate(dateString: "2016-07-27"), context: "Working at home", symptoms: [arnie_symptom], fife: "Thought it was muscle pain. Nervous to go to ER.", diagnostics: [], further_action: "Went to ER")


let arnie_ecg = Diagnostic(when: NSDate(dateString: "2016-07-28"), self_reported: false, labname: "ECG", value: 0.0, description: "Returned negative for heart attack")
let arnie_cxr = Diagnostic(when: NSDate(dateString: "2016-07-28"), self_reported: false, labname: "Chest Xray", value: 0.0, description: "Showed pleural separation of 4mm from the chest wall, positive for Pneumothorax")

let arnie_er = Visit(date: NSDate(dateString: "2016-07-28"), context: "Had sharp chest pain.", symptoms: [arnie_symptom], fife: "Thought it was muscle pain.", diagnostics: [arnie_ecg, arnie_cxr], physician: Physician(name: "Don Hargles", npi: 102004), location: "WUSTL Medical Center", date_out: NSDate(dateString: "2016-07-29"), description: "Went to the ER reporting sharp chest pain. Diagnosed with a small pneumothorax which did not require intervention", medications: [], procedures: [])

let arnie_pain = Medication(name: "Hydrocodone 325/5", reason: "Pain in the chest", warnings: ["Drowsiness", "Dizziness", "Faintness", "Do Not operate heavy machinery"], dose: "1-2 per 4 hours as needed. No more than 6 per 24 hours", start: NSDate(dateString: "2016-07-29"), end: nil)


let abillings94 = Patient(name: "Arnie Billings", dob: NSDate(dateString: "1994-10-16"), sex: true, gender: "Male", problems: [arnie_pneumo], personalHistory: [arnie_note, arnie_er], statusdata: arnie_status, ongoingMedications: [arnie_pain])

let arnie_dict = abillings94.encodeMe()

var unknown_patient: Patient = Patient(name: "", dob: NSDate(dateString: "2000-01-01"), sex: false, gender: "", problems: [], personalHistory: [], statusdata: Status(allergies: [], immunizations: []), ongoingMedications: [])

unknown_patient.decodeMe(arnie_dict)

let str = unknown_patient.name
print(str)