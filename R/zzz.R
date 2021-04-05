# For checking to see if any invalid countries have been used

valid_countries <- c("AA", "AC", "AE", "AF", "AG", "AJ", "AL", "AM", "AN", "AO",
                     "AQ", "AR", "AS", "AU", "AV", "BA", "BB", "BC", "BD", "BE", "BF",
                     "BG", "BH", "BK", "BL", "BM", "BN", "BO", "BP", "BR", "BT", "BU",
                     "BX", "BY", "CA", "CB", "CD", "CE", "CF", "CG", "CH", "CI", "CJ",
                     "CM", "CN", "CO", "CQ", "CS", "CT", "CU", "CV", "CW", "CY", "DA",
                     "DJ", "DO", "DR", "EC", "EG", "EI", "EK", "EN", "ER", "ES", "ET",
                     "EZ", "FI", "FJ", "FM", "FO", "FP", "FR", "GA", "GB", "GG", "GH",
                     "GI", "GJ", "GK", "GL", "GM", "GQ", "GR", "GT", "GV", "GY", "GZ",
                     "HA", "HK", "HO", "HR", "HU", "IC", "ID", "IM", "IN", "IR", "IS",
                     "IT", "IV", "IZ", "JA", "JE", "JM", "JO", "KE", "KG", "KN", "KR",
                     "KS", "KU", "KV", "KZ", "LA", "LE", "LG", "LH", "LI", "LO", "LS",
                     "LT", "LU", "LY", "MA", "MC", "MD", "MG", "MH", "MI", "MJ", "MK",
                     "ML", "MN", "MO", "MP", "MR", "MT", "MU", "MV", "MX", "MY", "MZ",
                     "NC", "NG", "NH", "NI", "NL", "NN", "NO", "NP", "NR", "NS", "NU",
                     "NZ", "OD", "PA", "PE", "PK", "PL", "PM", "PO", "PP", "PS", "PU",
                     "QA", "RI", "RM", "RN", "RO", "RP", "RQ", "RS", "RW", "SA", "SB",
                     "SC", "SE", "SF", "SG", "SH", "SI", "SL", "SM", "SN", "SO", "SP",
                     "ST", "SU", "SW", "SY", "SZ", "TB", "TD", "TH", "TI", "TK", "TN",
                     "TO", "TP", "TS", "TT", "TU", "TV", "TW", "TX", "TZ", "UC", "UG",
                     "UK", "UP", "US", "UV", "UY", "UZ", "VC", "VE", "VI", "VM", "VQ",
                     "WA", "WE", "WF", "WI", "WS", "WZ", "YM", "ZA", "ZI")


utils::globalVariables(c("Concept", "Name", "genc", "yr", "code", "iso_a2", "variables5"))