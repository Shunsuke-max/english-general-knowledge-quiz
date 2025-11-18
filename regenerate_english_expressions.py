#!/usr/bin/env python3
import json
import math
import os
import re
import string

BASE_DIR = os.path.dirname(__file__)
QUESTIONS_PATH = os.path.join(
    BASE_DIR, "EnglishGeneralKnowledge/EnglishGeneralKnowledge/SwiftQuizApp/Resources/questions.json"
)

MANUAL_DESCRIPTIONS = {
    # Populated later with manual descriptions for tricky terms.
}

KEYWORD_ALIASES = {
    "ocean": "a vast body of salt water",
    "sea": "a large saltwater area connected to an ocean",
    "river": "a flowing freshwater channel",
    "current": "a steady stream of water in an ocean or river",
    "mountain": "a high natural elevation",
    "range": "a chain of mountains",
    "gulf": "a portion of sea partially surrounded by land",
    "bay": "a curved inlet of the sea",
    "pass": "a mountain gap or route",
    "lake": "a body of inland water",
    "desert": "a dry region with little rainfall",
    "island": "land surrounded by water",
    "state": "a regional area with its own government",
    "country": "a sovereign nation",
    "capital": "a city's government center",
    "city": "an urban population center",
    "cities": "multiple urban population centers",
    "canal": "a human-made waterway",
    "planet": "a celestial body orbiting a star",
    "star": "a luminous ball of gas in space",
    "sun": "the star at the center of our Solar System",
    "moon": "Earth's natural satellite",
    "war": "a large armed conflict between countries",
    "wars": "large armed conflicts between countries",
    "treaty": "a formal agreement between nations",
    "treaties": "formal agreements between nations",
    "empire": "a group of territories ruled by one leader",
    "revolution": "a major political or social change",
    "president": "the elected head of a republic",
    "king": "a male monarch",
    "queen": "a female monarch",
    "artist": "a creator of music, painting, or film",
    "composer": "someone who writes music",
    "mammal": "a warm-blooded animal that usually has hair and milk",
    "bird": "a feathered animal that often flies",
    "fish": "a cold-blooded aquatic animal that has gills",
    "reptile": "a cold-blooded, scaly animal",
    "amphibian": "an animal living in water and on land",
    "word": "a unit of language",
    "language": "a system of communication",
    "food": "something eaten for nutrition",
    "art": "human creative expression",
    "science": "systematic study of the natural world",
    "technology": "applied engineering or devices",
    "sport": "a physical competition",
    "device": "a machine built for a task",
    "invention": "a new tool or method",
    "computer": "an electronic information processor",
    "software": "a set of instructions for computers",
    "protocol": "a rule for data exchange",
}

WORD_DEFINITIONS = {
    "tilt": "the angle at which Earth's axis leans",
    "distance": "how far apart two things are",
    "sunlight": "the light and warmth coming from the Sun",
    "oxygen": "the gas we breathe and plants release",
    "carbon": "the element that forms many gases",
    "dioxide": "a molecule with one carbon and two oxygen atoms",
    "solar": "related to the Sun",
    "flare": "a sudden burst of energy",
    "ocean": "a huge body of salt water",
    "current": "a steady stream of moving water",
    "currents": "steady streams of moving water",
    "water": "the liquid that covers most of Earth",
    "denser": "having more packed molecules",
    "vibration": "a back-and-forth movement that carries sound",
    "sound": "waves that travel through air or water",
    "year": "a unit of time based on Earth's orbit",
    "planet": "a world that orbits a star",
    "ring": "a circular band surrounding a planet",
    "system": "a group of connected parts",
    "stem": "the stalk of a plant",
    "root": "the underground part of a plant that takes in water",
    "cloud": "a floating collection of water vapor",
    "rain": "water droplets falling from clouds",
    "code": "a system of symbols used for communication",
    "telegraph": "an old system for sending coded messages over wires",
    "telephone": "a device people use to talk across distance",
    "radio": "a wireless signal carrying sound",
    "printing": "producing copies of text or images",
    "press": "a machine that prints text",
    "electric": "powered by electricity",
    "signal": "an electrical or radio impulse",
    "continent": "a large landmass",
    "capital": "the city where a country's government sits",
    "city": "a large populated urban area",
    "mountain": "a big elevated landform",
    "mountains": "multiple high elevated landforms",
    "river": "a flowing body of water",
    "rivers": "multiple flowing bodies of water",
    "forest": "a large area filled with trees",
    "desert": "an arid region with little water",
    "deserts": "arid regions with little water",
    "sea": "a smaller body of salt water connected to an ocean",
    "earth": "the planet we live on",
    "axis": "an imaginary line through a spinning object",
    "air": "the mixture of gases around Earth",
    "heat": "the energy that raises temperature",
    "pressure": "force applied to an area",
    "system": "a group of parts working together",
    "power": "energy or strength someone uses",
    "light": "visible energy emitted by the Sun or lamps",
    "laser": "a narrow beam of light",
    "meter": "a unit of length",
}

SPECIAL_DESCRIPTIONS = {
    "Toronto": "Canada's largest city and a financial hub",
    "Vancouver": "a Pacific coast city known for mountains and technology",
    "Montreal": "the French-speaking city in Quebec with deep culture",
    "Ottawa": "Canada's capital city where the federal government sits",
    "Beijing": "China's capital city",
    "Paris": "France's capital, famous for art and monuments",
    "Rome": "Italy's capital, home to ancient ruins",
    "Buenos Aires": "Argentina's capital on the Rio de la Plata",
    "Brazil": "the largest country in South America",
    "China": "the populous Asian nation with a long history",
    "Japan": "an island nation in East Asia",
    "South Korea": "a technologically advanced nation on the Korean Peninsula",
    "Egypt": "the North African country of the Nile",
    "Benjamin Franklin": "a Founding Father of the United States",
    "Thomas Jefferson": "the third U.S. president",
    "Caligula": "a Roman emperor known for excess",
    "Augustus": "the first Roman emperor",
    "Vasco da Gama": "the explorer who sailed to India around Africa",
    "Christopher Columbus": "the navigator credited with reaching the Americas",
    "Persian Empire": "the ancient land ruled from modern-day Iran",
    "Treaty of Versailles": "the agreement that ended World War I",
    "World War Ⅰ": "the first major global conflict of the 20th century",
    "World War Ⅱ": "the second global conflict that followed",
    "Sahara": "the vast desert in northern Africa",
    "Amazon Prime": "Amazon's streaming service and delivery club",
    "Disney+": "Disney's streaming platform for shows and films",
    "Star Wars": "a space-opera film franchise",
    "The Lord of the Rings": "J.R.R. Tolkien's epic fantasy saga",
    "The Wheel of Time": "a fantasy novel series by Robert Jordan",
    "Black Panther": "a Marvel hero and film",
    "Captain America": "a Marvel superhero symbolizing America",
    "Doctor Strange": "a sorcerer superhero in the Marvel universe",
    "Thor": "a Norse god and Marvel superhero wielding a hammer",
    "Indiana Jones": "an adventure movie archaeologist",
    "Python": "a popular programming language",
    "Java": "another programming language",
    "Wi-Fi": "a wireless networking technology",
    "Bluetooth": "short-range wireless communication",
    "USB": "a common connector for data and charging",
    "LED": "a light-emitting diode used in displays and bulbs",
    "CPU": "the central processing unit inside a computer",
    "Thames": "the river that flows through London and into the North Sea",
    "Danube": "a long river that passes through Central and Eastern Europe",
    "Rhine": "a major river flowing from the Alps to the North Sea",
    "Seine": "the river that runs through Paris into the English Channel",
    "Nile": "the longest river in Africa running north to the Mediterranean",
    "Amazon": "the vast river and rainforest system in South America",
    "Zambezi": "a southern African river feeding Victoria Falls",
    "Pacific Ocean": "the largest ocean on Earth",
    "Atlantic Ocean": "the ocean between the Americas and Europe/Africa",
    "Indian Ocean": "the ocean south of Asia and east of Africa",
    "Arctic Ocean": "the polar ocean around the North Pole",
    "Red Sea": "the saltwater inlet between Africa and Arabia",
    "Persian Gulf": "the gulf between Iran and the Arabian Peninsula",
    "Suez Canal": "the ship canal connecting the Mediterranean and Red Seas",
    "Bosphorus": "the strait dividing Europe and Asia through Istanbul",
    "Strait of Gibraltar": "the narrow passage between Spain and Morocco",
    "Chimborazo": "an Ecuadorian volcano near the equator",
    "K2": "the second-highest mountain on Earth",
    "Mount Everest": "Earth's tallest peak in the Himalayas",
    "Rockies": "the mountain range running through western North America",
    "Andes": "the mountain range along South America's western edge",
    "Sahara": "the huge desert across North Africa",
    "Ganges": "a sacred river flowing through India and Bangladesh",
    "Pacific": "a name often used for the Pacific Ocean",
    "Amazon Prime": "Amazon's premium subscription service",
    "Disney+": "Disney's streaming video service",
    "A Song of Ice and Fire": "the fantasy novel series by George R.R. Martin",
    "The Lord of the Rings": "Tolkien's high-fantasy story about a ring",
    "Star Wars": "a science-fiction saga set in space",
    "The Wheel of Time": "a sprawling fantasy series originally written by Robert Jordan",
}

ELEMENT_DESCRIPTIONS = {
    "hydrogen": "the lightest element, often used as fuel but too light to trap heat in the atmosphere",
    "oxygen": "the gas we breathe and plants release, which supports combustion but does not absorb the infrared wavelengths that drive the greenhouse effect",
    "carbon dioxide": "the greenhouse gas produced when living things breathe and when fossil fuels burn, so it holds heat in the atmosphere",
    "neon": "a noble and inert gas used in glowing signage, and because it does not absorb infrared light it does not contribute to the greenhouse effect",
    "nitrogen": "a major component of Earth's air, used in fertilizers and mostly inactive in trapping heat",
    "methane": "a greenhouse gas released from wetlands and livestock that traps heat more efficiently than carbon dioxide",
    "helium": "an inert gas lighter than air, used in balloons and cooling, with no greenhouse contribution",
    "argon": "an inert gas often used in lighting and welding that also does not absorb the heat-trapping wavelengths",
}

PERSON_DESCRIPTIONS = {
    "Adele": "the Grammy-winning British singer",
    "Amy Winehouse": "the late British singer with soulful jazz-pop",
    "Beethoven": "the German composer behind famous symphonies",
    "Brahms": "a Romantic-era German composer",
    "Benjamin Franklin": "a Founding Father of the United States",
    "Thomas Jefferson": "the third U.S. president and Declaration signer",
    "Vladimir Lenin": "the revolutionary leader of Soviet Russia",
    "Caligula": "a Roman emperor remembered for excess",
    "Augustus": "Rome's first emperor who stabilized the empire",
    "Christopher Columbus": "the navigator credited with reaching the Americas",
    "Vasco da Gama": "the explorer who sailed from Portugal to India",
    "Rajendra Prasad": "the first president of independent India",
}

WORK_DESCRIPTIONS = {
    "Star Wars": "a worldwide film franchise about space battles",
    "The Lord of the Rings": "J.R.R. Tolkien's fantasy epic",
    "The Wheel of Time": "a fantasy novel series by Robert Jordan",
    "A Song of Ice and Fire": "George R.R. Martin's fantasy saga",
    "The Big Bang Theory": "a sitcom about scientists",
}

SPORT_DESCRIPTIONS = {
    "Baseball": "a bat-and-ball game popular in America and Japan",
    "Basketball": "a team sport with hoops and a bouncing ball",
    "Cricket": "a bat-and-ball sport played with overs",
    "Curling": "a winter sport sliding stones on ice",
    "Volleyball": "a net sport with teams hitting a ball",
    "Rugby": "a physical sport played with an oval ball",
    "Skating": "moving gracefully on ice or rollers",
    "Hockey": "a team sport played on ice or turf with sticks",
    "Bobsled": "a winter sport racing on ice tracks",
    "Formula One": "a high-speed auto racing championship",
}

TECH_DESCRIPTIONS = {
    "Wi-Fi": "wireless networking technology for the internet",
    "Bluetooth": "a short-range wireless connection standard",
    "USB": "a common cable interface for data and power",
    "LED": "a diode that emits light when powered",
    "RFID": "a method of identifying via radio waves",
    "CPU": "the chip that executes programs",
    "GPU": "a processor optimized for graphics",
    "SSD": "a solid-state storage drive",
    "HDD": "a hard disk drive",
    "AI engineering": "the practice of building artificial intelligence systems",
}

ANIMAL_DESCRIPTIONS = {
    "Cheetah": "the fastest land cat capable of short bursts of speed",
    "Dolphin": "a smart marine mammal known for leaping",
    "Shark": "a predator fish with multiple rows of teeth",
    "Elephant": "Earth's largest land mammal with tusks",
    "Penguin": "a flightless seabird adapted to cold waters",
    "Whale": "a massive marine mammal",
    "Hummingbird": "a tiny bird that hovers by beating wings quickly",
    "Sparrow": "a small common bird",
    "Albatross": "a large seabird with long wings",
    "Seal": "a marine mammal living near coasts",
}

DESCRIPTION_OVERRIDES = {}
for collection in (
    SPECIAL_DESCRIPTIONS,
    PERSON_DESCRIPTIONS,
    WORK_DESCRIPTIONS,
    SPORT_DESCRIPTIONS,
    TECH_DESCRIPTIONS,
    ANIMAL_DESCRIPTIONS,
    ELEMENT_DESCRIPTIONS,
):
    for key, value in collection.items():
        DESCRIPTION_OVERRIDES[key.lower()] = value


PHRASE_PATTERNS = [
    ({"distance", "sun"}, "how far Earth is from the Sun"),
    ({"tilt", "axis"}, "the angle at which Earth leans while spinning"),
    ({"solar", "flare"}, "a burst of energy from the Sun's surface"),
    ({"solar", "flares"}, "bursts of charged particles from the Sun"),
    ({"ocean", "current"}, "the steady movement of ocean water"),
    ({"ocean", "currents"}, "the steady movement of ocean water"),
    ({"water", "denser"}, "the idea that packed water molecules pass vibrations faster"),
    ({"water", "colder"}, "the cooler temperature of water bodies"),
    ({"water", "oxygen"}, "oxygen dissolved or present in water"),
    ({"water", "moves"}, "how water flows or shifts"),
    ({"planet", "rings"}, "a planet surrounded by rings of rock and ice"),
    ({"capital", "city"}, "a city where national leaders gather"),
    ({"treaty"}, "a formal agreement between countries"),
    ({"war"}, "a large armed conflict between nations"),
    ({"photosynthesis"}, "the process in which plants create their own food using sunlight"),
]


def tokenize(text: str):
    cleaned = text.lower()
    translator = str.maketrans(string.punctuation, " " * len(string.punctuation))
    cleaned = cleaned.translate(translator)
    return [word for word in cleaned.split() if word]


def match_phrase(words):
    word_set = set(words)
    for pattern_words, description in PHRASE_PATTERNS:
        if pattern_words.issubset(word_set):
            return description
    return None


def describe_option(option: str):
    cleaned = option.strip()
    words = tokenize(cleaned)

    description = None
    option_key = cleaned.lower()
    if option_key in DESCRIPTION_OVERRIDES:
        description = DESCRIPTION_OVERRIDES[option_key]
    else:
        pattern_result = match_phrase(words)
        if pattern_result:
            description = pattern_result
        elif words and all(word.isdigit() for word in words):
            description = f"the year {cleaned}"
        elif cleaned.endswith("%") and cleaned[:-1].replace(".", "").isdigit():
            description = f"the percentage {cleaned}"
        else:
            fragments = []
            seen = set()
            for word in words:
                if word in WORD_DEFINITIONS and word not in seen:
                    fragments.append(WORD_DEFINITIONS[word])
                    seen.add(word)
                elif word in KEYWORD_ALIASES and word not in seen:
                    fragments.append(KEYWORD_ALIASES[word])
                    seen.add(word)
                elif word not in seen:
                    fragments.append(word)
                    seen.add(word)
            if fragments:
                description = " ".join(fragments)
            else:
                description = cleaned

    return description


PREFIX_TEMPLATES = [
    "For \"{topic}\", {answer} is correct because {explanation}.",
    "\"{topic}\" points at {answer}; {explanation}.",
    "Remember that {answer} answers \"{topic}\"—{explanation}.",
    "{topic} makes sense with {answer} since {explanation}.",
]


def clean_topic(text: str):
    return text.strip().rstrip("?.")


def build_english_expression(question_data, idx):
    topic = clean_topic(question_data["question"])
    explanation = question_data["explanation"].strip()
    if explanation.endswith("."):
        explanation = explanation[:-1]
    answer = question_data["answer"]
    prefix = PREFIX_TEMPLATES[idx % len(PREFIX_TEMPLATES)].format(
        topic=topic, answer=answer, explanation=explanation
    )

    others = [opt for opt in question_data["options"] if opt != answer]
    desc_sentences = []
    for option in others:
        desc = describe_option(option)
        desc_sentences.append(
            f"\"{option}\" refers to {desc}; that focus differs from {answer}, so it doesn't match {topic}."
        )

    closing = f"Keep {answer} in mind the next time you see \"{topic}\"."
    return " ".join([prefix, *desc_sentences, closing])


def main():
    with open(QUESTIONS_PATH, encoding="utf-8") as f:
        data = json.load(f)

    for idx, question in enumerate(data):
        question["englishExpression"] = build_english_expression(question, idx)

    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
