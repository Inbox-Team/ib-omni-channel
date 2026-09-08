export const PRE_CHAT_SUGGESTIONS = [
  { title: 'View the latest room rates', value: 'View the latest room rates' },
  {
    title: 'Check room availability for today',
    value: 'Check room availability for today',
  },
  {
    title: "What are this month's special offers/combos?",
    value: "What are this month's special offers/combos?",
  },
  { title: 'Quick booking guide', value: 'Quick booking guide' },
  {
    title: 'What is the cancellation policy?',
    value: 'What is the cancellation policy?',
  },
  {
    title: 'Where is Kin Hotel located?',
    value: 'Where is Kin Hotel located?',
  },
  { title: 'Kin Hotel address', value: 'Kin Hotel address' },
  {
    title: 'Does the hotel have parking available?',
    value: 'Does the hotel have parking available?',
  },
  {
    title: 'How to get to Kin Hotel from the airport',
    value: 'How to get to Kin Hotel from the airport',
  },
  {
    title: 'What attractions/things to do are around the hotel?',
    value: 'What attractions/things to do are around the hotel?',
  },
  {
    title: 'Check-in/Check-out times?',
    value: 'Check-in/Check-out times?',
  },
  { title: 'Is breakfast included?', value: 'Is breakfast included?' },
  {
    title: 'View actual photos of the rooms',
    value: 'View actual photos of the rooms',
  },
  {
    title: 'Do you offer honeymoon room decoration services?',
    value: 'Do you offer honeymoon room decoration services?',
  },
  {
    title: 'Connect with a receptionist',
    value: 'Connect with a receptionist',
  },
  {
    title: 'What is the Wi-Fi password?',
    value: 'What is the Wi-Fi password?',
  },
  {
    title: 'Request room cleaning / extra amenities',
    value: 'Request room cleaning / extra amenities',
  },
];

export const getRandomPreChatSuggestions = (count = 6) => {
  const suggestions = [...PRE_CHAT_SUGGESTIONS];

  for (let index = suggestions.length - 1; index > 0; index -= 1) {
    const randomIndex = Math.floor(Math.random() * (index + 1));
    [suggestions[index], suggestions[randomIndex]] = [
      suggestions[randomIndex],
      suggestions[index],
    ];
  }

  return suggestions.slice(0, count);
};
