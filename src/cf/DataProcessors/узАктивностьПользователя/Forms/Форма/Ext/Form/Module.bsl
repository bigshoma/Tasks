﻿
&НаКлиенте
Процедура ТабличныйДокумент_АктивностиОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	Если СтрНачинаетсяС( Расшифровка, "ДеньАктивности" ) Тогда
	
		СтандартнаяОбработка = Ложь;
		
		структОтбор = Новый Структура( "День", Дата( СтрЗаменить( Расшифровка, "ДеньАктивности", "") ));
		
		Элементы.ТаблицаАктивностей.ОтборСтрок = Новый ФиксированнаяСтруктура( структОтбор );
	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТестовымиДанными(Команда)
	
	//ЗаполнитьТестовымиДаннымиСервер();
	
КонецПроцедуры

Процедура Удалить_ЗаполнитьТестовымиДаннымиСервер()

	Объект.ТаблицаАктивностей.Очистить();
	
	ГСЧ = Новый ГенераторСлучайныхЧисел();

	структНастройки = ПолучитьНастройки( 100 );
	
	текДень = структНастройки.ПервыйДень;
	
	Пока текДень <= структНастройки.ПоследнийДень Цикл
		
		Если ДеньНедели( текДень ) = 6
			ИЛИ ДеньНедели( текДень ) = 7 Тогда
			максАктивностей = 20;
		Иначе
			максАктивностей = 100;
		КонецЕсли;
		
		Для ц = 0 По ГСЧ.СлучайноеЧисло( 0, максАктивностей ) Цикл
			
			новСтрока = Объект.ТаблицаАктивностей.Добавить();
			
			новСтрока.Период = текДень;
			новСтрока.Описание = ц;
			
		КонецЦикла;
		
		текДень = текДень + Сутки();
		
	КонецЦикла;
	
	ЗаполнитьНаСервере();
	
КонецПроцедуры


&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
	
	пДеньАктивности = "ДеньАктивности" + Формат(ТекущаяДатаНаСервере(), "ДФ=yyyyMMddhhmmss" );
	структОтбор = Новый Структура( "День", Дата( СтрЗаменить( пДеньАктивности, "ДеньАктивности", "") ));
	
	Элементы.ТаблицаАктивностей.ОтборСтрок = Новый ФиксированнаяСтруктура( структОтбор );	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	ЗаполнитьТаблицуАктивностей();	
	Для каждого цСтрока Из Объект.ТаблицаАктивностей Цикл
		цСтрока.День = НачалоДня( цСтрока.Период );
	КонецЦикла;
	
	тзАктивности = Объект.ТаблицаАктивностей.Выгрузить(, "День");
	тзАктивности.Колонки.Добавить( "Количество" );
	тзАктивности.ЗаполнитьЗначения( 1, "Количество" );
	тзАктивности.Свернуть( "День", "Количество" );
	
	максКоличество = 0;
	
	Для каждого цСтрока Из тзАктивности Цикл
		
		максКоличество = Макс( максКоличество, цСтрока.Количество );
		
	КонецЦикла;
	
	структНастройки = ПолучитьНастройки(максКоличество);
	
	ТабличныйДокумент_Активности = СоздатьТабличныйДокументАктивности( тзАктивности, структНастройки );
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуАктивностей()
	Объект.ТаблицаАктивностей.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	узАктивностиПользователей.ДатаАктивности,
	|	узАктивностиПользователей.СсылкаНаОбъект,
	|	узАктивностиПользователей.Пользователь,
	|	узАктивностиПользователей.ВидСобытия,
	|	узАктивностиПользователей.Описание,
	|	узАктивностиПользователей.ДеньАктивности
	|ИЗ
	|	РегистрСведений.узАктивностиПользователей КАК узАктивностиПользователей
	|ГДЕ
	|	узАктивностиПользователей.Пользователь = &Пользователь";
	
	Запрос.УстановитьПараметр("Пользователь", Объект.Пользователь);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл		
		СтрокаТаблицаАктивностей = Объект.ТаблицаАктивностей.Добавить();	
		СтрокаТаблицаАктивностей.Период = Выборка.ДатаАктивности;
		СтрокаТаблицаАктивностей.Описание = Выборка.Описание;
		СтрокаТаблицаАктивностей.День = Выборка.ДеньАктивности;
		СтрокаТаблицаАктивностей.СсылкаНаОбъект = Выборка.СсылкаНаОбъект;
		СтрокаТаблицаАктивностей.Пользователь = Выборка.Пользователь;
		СтрокаТаблицаАктивностей.ВидСобытия = Выборка.ВидСобытия;
	КонецЦикла;
	
КонецПроцедуры 

&НаСервереБезКонтекста
Функция ПолучитьНастройки(Знач максКоличество)
	
	структНастройки = Новый Структура();
	структНастройки.Вставить( "ПервыйДень",  НачалоДня( ДобавитьМесяц( ТекущаяДатаСеанса(), -12) + Сутки()));
	структНастройки.Вставить( "ПоследнийДень", НачалоДня( ТекущаяДатаСеанса() ));
	
	массивПалитра = Новый Массив;
	//массивПалитра.Добавить( Новый Цвет(225,225,225) );
	//массивПалитра.Добавить( Новый Цвет(173,213,247) );
	//массивПалитра.Добавить( Новый Цвет(127,178,240) );
	//массивПалитра.Добавить( Новый Цвет(78,122,199) );
	//массивПалитра.Добавить( Новый Цвет(53,71,140) );
	//массивПалитра.Добавить( Новый Цвет(22,25,59) );
	
	//массивПалитра.Добавить( Новый Цвет(235,237,240) );
	массивПалитра.Добавить(ЦветаСтиля.узАктивностьЦветСветлоСерый);
	//массивПалитра.Добавить( Новый Цвет(198,228,139) );	
	массивПалитра.Добавить(ЦветаСтиля.узАктивностьЦветСветлоЗеленый);
	//массивПалитра.Добавить( Новый Цвет(123,201,111) );	
	массивПалитра.Добавить(ЦветаСтиля.узАктивностьЦветЗеленый);
	//массивПалитра.Добавить( Новый Цвет(35,154,59) );	
	массивПалитра.Добавить(ЦветаСтиля.узАктивностьЦветТемноЗеленый);	
	//массивПалитра.Добавить( Новый Цвет(25, 97, 39) );
	массивПалитра.Добавить(ЦветаСтиля.узАктивностьЦветСильноТемноЗеленый);
	
	//массивПалитра.Добавить( Новый Цвет(23,78,52) );	
	
	структНастройки.Вставить( "Палитра", массивПалитра );
	
	массивГраницы = Новый Массив;
	массивГраницы.Добавить(0);
	массивГраницы.Добавить(1);
	//массивГраницы.Добавить(Макс( 1, максКоличество * 0.2));
	//массивГраницы.Добавить(Макс( 1, максКоличество * 0.4));
	//массивГраницы.Добавить(Макс( 1, максКоличество * 0.6));
	//массивГраницы.Добавить(Макс( 1, максКоличество * 0.8));
	массивГраницы.Добавить(Макс( 1, максКоличество * 0.25));
	массивГраницы.Добавить(Макс( 1, максКоличество * 0.5));
	массивГраницы.Добавить(Макс( 1, максКоличество * 0.75));
	
	структНастройки.Вставить( "Границы", массивГраницы );
	
	Возврат структНастройки;

КонецФункции

&НаСервереБезКонтекста
Функция СоздатьТабличныйДокументАктивности( Знач пТаблицаАктивностей, Знач пНастройки )
	
	таблДок = Новый ТабличныйДокумент;
	
	ПрисоединитьКолонкуДней(таблДок);
	
	облКвадратик = таблДок.ПолучитьОбласть("R1C1");
	облЯчеекКвадратика = НастроитьОбластьЯчеекКвадратика(облКвадратик);
	
	текНеделя = НачалоНедели( пНастройки.ПервыйДень );
	
	Пока текНеделя <= пНастройки.ПоследнийДень Цикл
		
		облМесяц = ПолучитьОбластьМесяца(таблДок);
		
		колонкаНеделя = Новый ТабличныйДокумент;
		
		месяцНачалаНедели = НачалоМесяца( текНеделя );
		месяцКонцаНедели = НачалоМесяца( КонецНедели( текНеделя ) );
		
		естьСменаМесяца = Не месяцНачалаНедели = месяцКонцаНедели ИЛИ текНеделя = месяцНачалаНедели;
		
		Если естьСменаМесяца
			ИЛИ текНеделя <= пНастройки.ПервыйДень Тогда
			
			облМесяц.Область("R1C1").Текст = Формат( месяцКонцаНедели, "ДФ=MMMM" );
			
		КонецЕсли;
		
		колонкаНеделя.Вывести( облМесяц );
		
		Для ц = 0 По 6 Цикл
			
			текДень = НачалоДня( текНеделя + ц*Сутки() );
			
			Если текДень < пНастройки.ПервыйДень
				ИЛИ текДень > пНастройки.ПоследнийДень Тогда
				
				облЯчеекКвадратика.Текст = "";
				//облЯчеекКвадратика.ЦветФона = Новый Цвет(255,255,255);
				облЯчеекКвадратика.ЦветФона = ЦветаСтиля.узАктивностьЦветБелый;
				
			Иначе
				
				облЯчеекКвадратика.Гиперссылка = Истина;
				облЯчеекКвадратика.ПараметрРасшифровки = "ДеньАктивности";
				облКвадратик.Параметры.ДеньАктивности = "ДеньАктивности" + Формат( текДень, "ДФ=yyyyMMddhhmmss" );
				
				текСтрока = пТаблицаАктивностей.Найти( текДень, "День" );
				
				облЯчеекКвадратика.Текст    = ТекстКвадратика(текДень, текСтрока);
				//{ Павлюков - Задача 132
				облЯчеекКвадратика.Текст = облЯчеекКвадратика.Текст + Символы.ПС + "  ";
				//}
				облЯчеекКвадратика.ЦветФона = ЦветФонаКвадратика(текСтрока, пНастройки);
				                                                                      
			КонецЕсли;
			
			Если естьСменаМесяца Тогда
				
				Если текДень = месяцНачалаНедели Тогда
					облЯчеекКвадратика.ГраницаСверху = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 2);
				Иначе
					облЯчеекКвадратика.ГраницаСверху = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				КонецЕсли;
				
				Если текДень = НачалоДня( КонецМесяца( месяцНачалаНедели ) ) Тогда
					облЯчеекКвадратика.ГраницаСнизу = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 2);
				Иначе
					облЯчеекКвадратика.ГраницаСнизу = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				КонецЕсли;
				
				Если текДень >= месяцКонцаНедели Тогда
					облЯчеекКвадратика.ГраницаСлева  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 2);
				Иначе
					облЯчеекКвадратика.ГраницаСлева  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				КонецЕсли;
				
				Если текДень < месяцКонцаНедели Тогда
					облЯчеекКвадратика.ГраницаСправа  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 2);
				Иначе
					облЯчеекКвадратика.ГраницаСправа  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				КонецЕсли;
				
			Иначе
				
				облЯчеекКвадратика.ГраницаСверху = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				облЯчеекКвадратика.ГраницаСнизу  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				облЯчеекКвадратика.ГраницаСлева  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				облЯчеекКвадратика.ГраницаСправа = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
				
			КонецЕсли;
			
			колонкаНеделя.Вывести( облКвадратик );
			
		КонецЦикла;
		
		текНеделя = НачалоНедели( текНеделя + 7*Сутки() );
		
		таблДок.Присоединить( колонкаНеделя );
		
	КонецЦикла;
	
	таблДок.Вывести( таблДок.ПолучитьОбласть("R1C1") );
	
	строкаРасшифровки = Новый ТабличныйДокумент;
	
	строкаРасшифровки.Присоединить( таблДок.ПолучитьОбласть("R1C1") );
	
	облКвадратикРасшифровки = таблДок.ПолучитьОбласть("R1C1");
	облЯчеекКвадратикаРасшифровки = НастроитьОбластьЯчеекКвадратика(облКвадратикРасшифровки);
	
	Для каждого цЦвет Из пНастройки.Палитра Цикл
		
		облЯчеекКвадратикаРасшифровки.ЦветФона = цЦвет;
		
		строкаРасшифровки.Присоединить( облКвадратикРасшифровки );
		
	КонецЦикла;
	
	таблДок.Вывести( строкаРасшифровки );
	
	Возврат таблДок;
	
КонецФункции

&НаСервереБезКонтекста
Функция НастроитьОбластьЯчеекКвадратика(Знач облКвадратик)
	
	облЯчеекКвадратика = облКвадратик.Область("R1C1");
	облЯчеекКвадратика.ВысотаСтроки  = 12;
	облЯчеекКвадратика.ШиринаКолонки = 2.5;
	облЯчеекКвадратика.Отступ = 4;
	//облЯчеекКвадратика.ЦветРамки = Новый Цвет(255,255,255);
	облЯчеекКвадратика.ЦветРамки = ЦветаСтиля.узАктивностьЦветБелый;
	облЯчеекКвадратика.ГраницаСверху = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	облЯчеекКвадратика.ГраницаСнизу  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	облЯчеекКвадратика.ГраницаСлева  = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	облЯчеекКвадратика.ГраницаСправа = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	Возврат облЯчеекКвадратика;

КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьОбластьМесяца(Знач таблДок)
	
	облМесяц = таблДок.ПолучитьОбласть("R1C1");
	облМесяц.Область("R1C1").ВысотаСтроки  = 12;
	облМесяц.Область("R1C1").ШиринаКолонки = 2.5;
	облМесяц.Область("R1C1").ГоризонтальноеПоложение = ГоризонтальноеПоложение.Лево;
	облМесяц.Область("R1C1").РазмещениеТекста = ТипРазмещенияТекстаТабличногоДокумента.Авто;
	Возврат облМесяц;

КонецФункции

&НаСервереБезКонтекста
Функция ТекстКвадратика( Знач пТекДата, Знач пТекСтрокаАктивности = Неопределено)

	шаблон = "%1
	|%2";
	
	количествоАктивностей = 0;
	
	Если Не пТекСтрокаАктивности = Неопределено Тогда
		
		количествоАктивностей = пТекСтрокаАктивности.Количество;
		
	КонецЕсли;

	//комментарий = СтрокаСЧислом( НСтр( "ru='Нет активностей;%1 активность;;%1 активности;%1 активностей;%1 активности'" ), количествоАктивностей, ВидЧисловогоЗначения.Количественное, "L=ru");
	Если количествоАктивностей = 0 Тогда
	        
	    комментарий = НСтр( "ru='Нет активностей'" );
	        
	Иначе
	        
	    комментарий = СтроковыеФункцииКлиентСервер.СтрокаСЧисломДляЛюбогоЯзыка(";%1 активность;;%1 активности;%1 активностей;%1 активностей", количествоАктивностей);
	        
	КонецЕсли;
	
	Возврат СтрШаблон( шаблон, комментарий, Формат( пТекДата, "ДЛФ=DD" ));
	
КонецФункции

&НаСервереБезКонтекста
Функция ЦветФонаКвадратика( Знач пТекСтрокаАктивности = Неопределено, пНастройки )

	количествоАктивностей = 0;
	
	Если Не пТекСтрокаАктивности = Неопределено Тогда
		
		количествоАктивностей = пТекСтрокаАктивности.Количество;
		
	КонецЕсли;

	текИндексЦвета = 0;
	
	Для ц = 0 По пНастройки.Границы.ВГраница() Цикл
		
		Если пНастройки.Границы[ц] <= количествоАктивностей Тогда
			текИндексЦвета = ц;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат пНастройки.Палитра[текИндексЦвета];
	
КонецФункции



&НаСервереБезКонтекста
Процедура ПрисоединитьКолонкуДней(Знач таблДок)
	
	Секция = таблДок.ПолучитьОбласть("R1C1");
	Секция.Область("R1C1").ВысотаСтроки  = 12;
	Секция.Область("R1C1").ШиринаКолонки = 5;
	Секция.Область("R1C1").ГоризонтальноеПоложение = ГоризонтальноеПоложение.Право;
	
	колонкаДни = Новый ТабличныйДокумент;
	колонкаДни.Вывести( Секция );
	
	Для ц = 0 По 6 Цикл
		
		Секция.Область("R1C1").Текст = Формат( НачалоНедели( ТекущаяДатаСеанса() ) + ц*Сутки(), "ДФ=ddd" );
		колонкаДни.Вывести( Секция );
		
	КонецЦикла;
	
	таблДок.Присоединить( колонкаДни );
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция Сутки()

	Возврат 24*60*60;

КонецФункции // Сутки()

&НаКлиенте
Процедура ПользовательПриИзменении(Элемент)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.Пользователь = Пользователи.ТекущийПользователь();
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ТекущаяДатаНаСервере() 
	Возврат ТекущаяДатаСеанса();
КонецФункции





