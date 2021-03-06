﻿// Получение текущего статуса объекта
//
// Параметры:
//  Владелец  - ДокументСсылка, СправочникСсылка - владелец статуса
//  Вид  - ПланФидовХарактеристикСсылка.tss_sc_ВидыСтатусов - вид статуса владельца
//
// Возвращаемое значение:
//   СправочникСсылка.tss_sc_ЗначенияСтатусов   - статус или пустая ссылка если статус не установлен
//
Функция ПолучитьСтатусОбъекта(Владелец, Вид) Экспорт

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ВладелецСтатуса", Владелец);
	Запрос.УстановитьПараметр("ВидСтатуса", Вид);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СтатусыОбъектов.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.tss_sc_СтатусыОбъектов КАК СтатусыОбъектов
	|ГДЕ
	|	СтатусыОбъектов.ВладелецСтатуса = &ВладелецСтатуса
	|	И СтатусыОбъектов.ВидСтатуса = &ВидСтатуса";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Значение;
	Иначе
		Возврат Справочники.tss_sc_ЗначенияСтатусов.ПустаяСсылка();
	КонецЕсли; 
	
КонецФункции // ПолучитьСтатусОбъекта()
 
// Получение соответсвия статусов объекта
//
// Параметры:
//  Владелец  - ДокументСсылка, СправочникСсылка - владелец статуса
//
// Возвращаемое значение:
//   Соответствие   - соответствие статусов где: Ключ - вид статуса, Значение - статус объекта
//
Функция ПолучитьСтатусыОбъекта(Владелец) Экспорт

	СоответствиеСтатусов = Новый Соответствие;
	
	ОбъектМетаданных = Владелец.Метаданные();
	ПолноеИмя = ОбъектМетаданных.ПолноеИмя();                          
	Если Найти(ПолноеИмя, "Документ.") = 1 Тогда
		МенеджерВладельца = Документы[ОбъектМетаданных.Имя];
	ИначеЕсли Найти(ПолноеИмя, "Справочник.") = 1 Тогда
		МенеджерВладельца = Справочники[ОбъектМетаданных.Имя].ПустаяСсылка();
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ВладелецСтатуса", Владелец);
	Запрос.УстановитьПараметр("ТипВладельца", МенеджерВладельца.ПустаяСсылка());
	Запрос.УстановитьПараметр("ПустойСтатус", Справочники.tss_sc_ЗначенияСтатусов.ПустаяСсылка()); 
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВидыСтатусовТипыВладельцев.Ссылка КАК ВидСтатуса,
	|	ЕСТЬNULL(СтатусыОбъектов.Значение, &ПустойСтатус) КАК Значение
	|ИЗ
	|	ПланВидовХарактеристик.tss_sc_ВидыСтатусов.ТипыВладельцев КАК ВидыСтатусовТипыВладельцев
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.tss_sc_СтатусыОбъектов КАК СтатусыОбъектов
	|		ПО ВидыСтатусовТипыВладельцев.Ссылка = СтатусыОбъектов.ВидСтатуса
	|			И (СтатусыОбъектов.ВладелецСтатуса = &ВладелецСтатуса)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.tss_sc_ВидыСтатусов КАК ВидыСтатусов
	|		ПО ВидыСтатусовТипыВладельцев.Ссылка = ВидыСтатусов.Ссылка
	|ГДЕ
	|	ВидыСтатусовТипыВладельцев.ТипВладельца = &ТипВладельца
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидыСтатусов.Код";
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СоответствиеСтатусов.Вставить(Выборка.ВидСтатуса, Выборка.Значение);
	КонецЦикла; 
	
	Возврат СоответствиеСтатусов;

КонецФункции // ПолучитьСтатусыОбъекта()
 
// Запись статуса владельца
//
// Параметры:
//  Владелец  - ДокументСсылка, СправочникСсылка - владелец статуса
//  Вид  - ПланФидовХарактеристикСсылка.tss_sc_ВидыСтатусов - вид статуса владельца
//  Значение - СправочникСсылка.tss_sc_ЗначенияСтатусов - статус который требуется установить
//
Процедура УстановитьСтатус(Владелец, Вид, Значение) Экспорт

	МенеджерЗаписи = РегистрыСведений.tss_sc_СтатусыОбъектов.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ВладелецСтатуса = Владелец;
	МенеджерЗаписи.ВидСтатуса = Вид;
	МенеджерЗаписи.Значение = Значение;
	МенеджерЗаписи.Записать();

КонецПроцедуры // УстановитьСтатус()
 